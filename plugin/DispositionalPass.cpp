#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Passes/PassBuilder.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Instructions.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/ADT/DenseMap.h"
#include "llvm/ADT/SmallVector.h"

using namespace llvm;

namespace {

// Enhanced tag system to handle negative values
enum class Tag : uint8_t { 
    Eps = 0,    // ε (nilpotent)
    I = 1,      // i (ascending FM)  
    J = 2,      // j (descending MF)
    Eta = 3,    // η (idempotent)
    NegEta = 4, // -η (for i² = -η)
    Zero = 5    // 0 (for ε² = 0)
};

// Corrected multiplication table based on paper's Appendix A.2
static const Tag TAG_MUL[6][6] = {
  /*           ε         i         j         η       -η        0   */
  /* ε */ {Tag::Zero, Tag::I,   Tag::J,   Tag::Eps, Tag::Eps, Tag::Zero},
  /* i */ {Tag::I,    Tag::NegEta, Tag::Eps, Tag::I,   Tag::I,   Tag::Zero},
  /* j */ {Tag::J,    Tag::Eta, Tag::Eta, Tag::J,   Tag::J,   Tag::Zero},
  /* η */ {Tag::Eps,  Tag::J,   Tag::I,   Tag::Eta, Tag::NegEta, Tag::Zero},
  /*-η */ {Tag::Eps,  Tag::J,   Tag::I,   Tag::NegEta, Tag::Eta, Tag::Zero},
  /* 0 */ {Tag::Zero, Tag::Zero, Tag::Zero, Tag::Zero, Tag::Zero, Tag::Zero}
};

inline Tag mul(Tag a, Tag b) { 
    return TAG_MUL[static_cast<int>(a)][static_cast<int>(b)]; 
}

// Path reduction according to paper's rules
Tag reduce(Tag t) {
    // Apply reduction rules: η² = η, ε² = 0, etc.
    switch (t) {
        case Tag::NegEta: return Tag::Eta; // Simplify -η to η for commutation test
        case Tag::Zero: return Tag::Zero;
        default: return t;
    }
}

// ---------------------------- TagBuilder ----------------------------------
struct TagBuilder {
    Tag classify(const Instruction &Inst) const {
        // More sophisticated classification based on paper's semantics
        if (isa<LoadInst>(Inst)) {
            return Tag::I;  // ascending read (F→M): YB
        }
        if (isa<StoreInst>(Inst)) {
            return Tag::J;  // descending write (M→F): AX  
        }
        if (isa<AllocaInst>(Inst)) {
            return Tag::Eta; // identity/allocation: AB
        }
        if (Inst.isTerminator()) {
            return Tag::Eta; // control flow identity
        }
        if (isa<GetElementPtrInst>(Inst)) {
            return Tag::Eps; // boundary operation: XY
        }
        if (isa<CastInst>(Inst)) {
            return Tag::Eps; // type boundary crossing
        }
        
        return Tag::Eps; // default boundary
    }
};

// ------------------------ Main analysis pass ------------------------------
struct DispositionalPass : public PassInfoMixin<DispositionalPass> {
    PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {
        
        TagBuilder TB;
        unsigned EdgeCnt = 0, CycleCnt = 0, GoodCycles = 0;
        
        // Build dispositional graph
        DenseMap<const BasicBlock*, SmallVector<std::pair<const BasicBlock*, Tag>>> G;
        
        // Tag all SSA edges
        for (auto &BB : F) {
            for (auto &I : BB) {
                Tag instTag = TB.classify(I);
                
                // For each operand, create an edge with dispositional tag
                for (const Use &U : I.operands()) {
                    if (auto *Def = dyn_cast<Instruction>(U.get())) {
                        G[Def->getParent()].push_back({&BB, instTag});
                        ++EdgeCnt;
                    }
                }
            }
        }
        
        // Cycle detection using simplified DFS
        DenseMap<const BasicBlock*, bool> Visited;
        DenseMap<const BasicBlock*, bool> InStack;
        
        std::function<void(const BasicBlock*, SmallVector<Tag>&)> dfs = 
            [&](const BasicBlock* V, SmallVector<Tag>& pathTags) {
                Visited[V] = true;
                InStack[V] = true;
                
                for (auto [W, tag] : G[V]) {
                    pathTags.push_back(tag);
                    
                    if (!Visited[W]) {
                        dfs(W, pathTags);
                    } else if (InStack[W]) {
                        // Found a cycle - check if it commutes
                        ++CycleCnt;
                        
                        // Multiply all tags in the cycle
                        Tag product = Tag::Eta; // identity
                        for (Tag t : pathTags) {
                            product = mul(product, t);
                        }
                        product = reduce(product);
                        
                        // Cycle commutes if product reduces to identity (η)
                        if (product == Tag::Eta) {
                            ++GoodCycles;
                        }
                    }
                    
                    pathTags.pop_back();
                }
                
                InStack[V] = false;
            };
        
        // Run DFS from each unvisited block
        for (auto &BB : F) {
            if (!Visited[&BB]) {
                SmallVector<Tag> pathTags;
                dfs(&BB, pathTags);
            }
        }
        
        // Output results in CSV format
        bool isSafe = (CycleCnt == 0) || (CycleCnt == GoodCycles);
        
        outs() << F.getParent()->getSourceFileName() << ","
               << F.getName() << ","
               << EdgeCnt << ","
               << CycleCnt << ","
               << GoodCycles << ","
               << (isSafe ? "safe" : "unsafe") << "\n";
        
        return PreservedAnalyses::all();
    }
};

} // end anonymous namespace

// ---- Plugin registration ----
extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
    return {
        LLVM_PLUGIN_API_VERSION, 
        "DispositionalPass", 
        "v0.1",
        [](PassBuilder &PB) {
            PB.registerPipelineParsingCallback(
                [](StringRef Name, FunctionPassManager &FPM,
                   ArrayRef<PassBuilder::PipelineElement>) {
                    if (Name == "dispositional-pass") {
                        FPM.addPass(DispositionalPass());
                        return true;
                    }
                    return false;
                });
        }
    };
}