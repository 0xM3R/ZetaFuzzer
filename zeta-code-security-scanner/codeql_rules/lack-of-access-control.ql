/**
 * @name Lack of Access Controls
 * @description Checks for the presence of access controls in the web3 application, which can allow an attacker to perform unauthorized actions.
 * @kind problem
 * @problem.severity high
 * @id js/access-controls
 */

import javascript

from CallExpr e
where e.getCallee().toString().matches("hasAccess|canAccess")
select e, "Access controls are not present in the application"
