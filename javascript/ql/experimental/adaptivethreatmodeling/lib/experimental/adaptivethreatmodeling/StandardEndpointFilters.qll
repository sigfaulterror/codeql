/**
 * For internal use only.
 *
 * Provides classes and predicates that are useful for endpoint filters.
 *
 * The standard use of this library is to make use of `isPotentialEffectiveSink/1`
 */

private import javascript

/**
 * Holds if the data flow node is a (possibly indirect) argument of a likely external library call.
 *
 * This includes direct arguments of likely external library calls as well as nested object
 * literals within those calls.
 */
predicate flowsToArgumentOfLikelyExternalLibraryCall(DataFlow::Node n) {
  n = getACallWithoutCallee().getAnArgument()
  or
  exists(DataFlow::SourceNode src | flowsToArgumentOfLikelyExternalLibraryCall(src) |
    n = src.getAPropertyWrite().getRhs()
  )
  or
  exists(DataFlow::ArrayCreationNode arr | flowsToArgumentOfLikelyExternalLibraryCall(arr) |
    n = arr.getAnElement()
  )
}

/**
 * Get calls which are likely to be to external non-built-in libraries.
 */
DataFlow::CallNode getALikelyExternalLibraryCall() { result = getACallWithoutCallee() }

/**
 * Gets a node that flows to callback-parameter `p`.
 */
private DataFlow::SourceNode getACallback(DataFlow::ParameterNode p, DataFlow::TypeBackTracker t) {
  t.start() and
  result = p and
  any(DataFlow::FunctionNode f).getLastParameter() = p and
  exists(p.getACall())
  or
  exists(DataFlow::TypeBackTracker t2 | result = getACallback(p, t2).backtrack(t2, t))
}

/**
 * Get calls for which we do not have the callee (i.e. the definition of the called function). This
 * acts as a heuristic for identifying calls to external library functions.
 */
private DataFlow::CallNode getACallWithoutCallee() {
  forall(Function callee | callee = result.getACallee() | callee.getTopLevel().isExterns()) and
  not exists(DataFlow::ParameterNode param, DataFlow::FunctionNode callback |
    param.flowsTo(result.getCalleeNode()) and
    callback = getACallback(param, DataFlow::TypeBackTracker::end())
  )
}
