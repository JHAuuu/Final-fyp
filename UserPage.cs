using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.Security;
using System.Security.Claims;

namespace fyp
{
    public class UserPage: Page
    {
        protected override void OnLoad(EventArgs e)
        {
             base.OnLoad(e); // Uncomment if there's a need to call the base implementation.

            // Check if the user is authenticated
            if (User.Identity.IsAuthenticated)
            {
                // Use ClaimsPrincipal to retrieve user claims
                var identity = (System.Security.Claims.ClaimsPrincipal)User;

                // Extract claims
                string userId = identity.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                string userRole = identity.FindFirst(ClaimTypes.Role)?.Value;
                string userName = identity.FindFirst(ClaimTypes.Name)?.Value;

                // Store user details in Session for further use (optional)
                Session["UserId"] = userId;
                Session["UserRole"] = userRole;
                Session["UserName"] = userName;
            }
            else
            {
                Response.Redirect("/error/401Unauthorized.aspx", true);
                // Redirect to Login if the user is not authenticated
                //Response.Redirect("Login.aspx", true);
            }
        }
    }
}