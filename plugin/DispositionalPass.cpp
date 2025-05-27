#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Passes/PassBuilder.h"

using namespace llvm;

namespace {

enum class Tag : uint8_t { Eps, I, J, Eta };

static const Tag TAG_MUL[4][4] = {
  /*          ε        i        j        η   */
  /* ε */ {Tag::Eps, Tag::I,  Tag::J,  Tag::Eps},
  /* i */ {Tag::I,   Tag::Eta,Tag::Eps,Tag::I},
  /* j */ {Tag::J,   Tag::Eta,Tag::Eta,Tag::J},
  /* η */ {Tag::Eps, Tag::J,  Tag::I,  Tag::Eta}
};

inline Tag mul(Tag a, Tag b) { return TAG_MUL[(int)a][(int)b]; }

// ---------------------------- TagBuilder ----------------------------------
struct TagBuilder {
  Tag classify(const Instruction &Inst) const {
    if (isa<LoadInst>(Inst))  return Tag::I;         // ascending read
    if (isa<StoreInst>(Inst)) return Tag::J;         // descending write
    if (isa<AllocaInst>(Inst) || Inst.isTerminator())
                                return Tag::Eta;     // identity edge
    return Tag::Eps;                                 // boundary default
  }
};

// ------------------------ Main analysis pass ------------------------------
struct DispositionalPass : public PassInfoMixin<DispositionalPass> {
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {

    TagBuilder TB;
    unsigned EdgeCnt = 0, CycleCnt = 0, GoodCycles = 0;

    DenseMap<const BasicBlock*, SmallVector<std::pair<const BasicBlock*, Tag>>> G;

    for (auto &BB : F)
      for (auto &I : BB) {
        Tag t = TB.classify(I);
        for (const Use &U : I.operands())
          if (auto *Def = dyn_cast<Instruction>(U.get())) {
            G[Def->getParent()].push_back({&BB, t});
            ++EdgeCnt;
          }
      }

    // ---------- Tarjan DFS ----------
    SmallVector<Tag> stackProd;
    DenseMap<const BasicBlock*, unsigned> DFN, Low;
    DenseMap<const BasicBlock*, bool>     OnStack;
    unsigned Time = 0;

    std::function<void(const BasicBlock*)> dfs =
      [&](const BasicBlock* V) {
        DFN[V] = Low[V] = ++Time;
        OnStack[V] = true;
        for (auto [W,tg] : G[V]) {
          if (!DFN[W]) { stackProd.push_back(tg); dfs(W); Low[V]=std::min(Low[V],Low[W]); }
          else if (OnStack[W]) { stackProd.push_back(tg); Low[V]=std::min(Low[V],DFN[W]); }
        }
        if (Low[V]==DFN[V]) {        // root of SCC
          Tag acc = Tag::Eta;
          while (!stackProd.empty()) { acc = mul(stackProd.back(), acc); stackProd.pop_back(); }
          ++CycleCnt;
          if (acc == Tag::Eta) ++GoodCycles;
          OnStack[V] = false;
        }
      };

    for (auto &BB : F)
      if (!DFN[&BB]) dfs(&BB);

    // ---------- CSV out ----------
    outs() << F.getParent()->getSourceFileName() << ','
           << F.getName() << ','
           << EdgeCnt     << ','
           << CycleCnt    << ','
           << GoodCycles  << ','
           << ((CycleCnt==GoodCycles) ? "safe" : "unsafe") << '\n';

    return PreservedAnalyses::all();
  }
};

} // end anonymous namespace
 

// ---- Plug-in registration boiler-plate ----------------------------------
extern "C" LLVM_ATTRIBUTE_WEAK ::llvm::PassPluginLibraryInfo
llvmGetPassPluginInfo() {
  return {
      LLVM_PLUGIN_API_VERSION, "DispositionalPass", "0.1",
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
      }};
}
