/**
 * @name Client-Side Validation
 * @description Checks if there is any client-side validation in the web3 application, which can be bypassed by an attacker and lead to security issues.
 * @kind problem
 * @problem.severity medium
 * @id js/client-side-validation
 */

import javascript

from CallExpr e
where e.getCallee().toString().matches("validate|check")
select e, "Client-side validation is used in the application"
