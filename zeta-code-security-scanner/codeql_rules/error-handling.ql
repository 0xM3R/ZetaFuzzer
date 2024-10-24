/**
 * @name Error Handling
 * @description Checks if there is proper error handling in the web3 application, which can prevent attackers from gaining valuable information about the application or its users.
 * @kind problem
 * @problem.severity medium
 * @id js/error-handling
 */

import javascript

from CallExpr e
where e.getCallee().toString().matches("catch|try|throw")
select e, "Proper error handling is not present in the application"
