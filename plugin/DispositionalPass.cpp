#include "llvm/IR/PassManager.h"
#include "llvm/Passes/PassPlugin.h"
#include "llvm/Passes/PassBuilder.h"

using namespace llvm;

namespace {


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
