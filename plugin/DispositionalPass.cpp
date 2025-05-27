#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Passes/PassBuilder.h"

using namespace llvm;

namespace {
enum class Tag : uint8_t { Eps, I, J, Eta };

static const Tag TAG_MUL[4][4] = {
/*          ε      i        j        η   */
/* ε */ {Tag::Eps, Tag::I,  Tag::J,  Tag::Eps},
/* i */ {Tag::I,   Tag::Eta,Tag::Eps,Tag::I},
/* j */ {Tag::J,   Tag::Eta,Tag::Eta,Tag::J},
/* η */ {Tag::Eps, Tag::J,  Tag::I,  Tag::Eta}
};

inline Tag mul(Tag a, Tag b) { return TAG_MUL[(int)a][(int)b]; }


struct TagBuilder {
  Tag classify(const Instruction &Inst) const {
    if (isa<LoadInst>(Inst))                return Tag::I;   // ascending read
    if (isa<StoreInst>(Inst))               return Tag::J;   // descending write
    if (isa<AllocaInst>(Inst) || Inst.isTerminator())
                                             return Tag::Eta; // identity edges
    return Tag::Eps;                                         // boundary default
  }
};


struct DispositionalPass : public PassInfoMixin<DispositionalPass> {
  PreservedAnalyses run(Function &F, FunctionAnalysisManager &) {
    // TODO: real ε/i/j/η analysis here
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
