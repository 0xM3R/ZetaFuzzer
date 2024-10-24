/**
 * @name find_casts_to_type_parameters
 * @kind problem
 * @problem.severity error
 * @tags security
 * @description Finds all instances of type assertions to type parameters.
 * @id javascript/find-casts-to-type-parameters
 */

import javascript

from TypeParameter param, TypeAssertion assertion
where assertion.getTypeAnnotation() = param.getLocalTypeName().getAnAccess()
select assertion, "Cast to type parameter."


