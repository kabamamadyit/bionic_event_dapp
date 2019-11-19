const errorString = "VM exception while processing transaction: ";

async function tryCatch(promise, reason) {
  try {
    await promise;
    throw null;
  } catch (error) {
    assert(error, "Expected a VM exception but did not get one");
    assert(
      error.message.indexOf(reason) != -1,
      "Expected an error starting with '" +
        errorString +
        reason +
        "' but got '" +
        error.message +
        "' instead"
    );
  }
}

module.exports = {
  catchRevert: async function(promise) {
    await tryCatch(promise, "revert");
  },
  catchRequire: async function(promise) {
    await tryCatch(promise, "require");
  },
  catchOutOfGas: async function(promise) {
    await tryCatch(promise, "out of gas");
  },
  catchInvalidJump: async function(promise) {
    await tryCatch(promise, "invalid JUMP");
  },
  catchInvalidOpcode: async function(promise) {
    await tryCatch(promise, "invalid opcode");
  },
  catchStackOverflow: async function(promise) {
    await tryCatch(promise, "stack overflow");
  },
  catchStackUnderflow: async function(promise) {
    await tryCatch(promise, "stack underflow");
  },
  catchStaticStateChange: async function(promise) {
    await tryCatch(promise, "static state change");
  }
};
