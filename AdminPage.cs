using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.Security;
using System.Security.Claims;
using Microsoft.Owin.Security;

namespace fyp.Authentication
{
    public class AdminPage: Page
    {
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            // Check if the user is authenticated
            // Check if the user is authenticated
            if (User.Identity.IsAuthenticated)
            {
                // Use ClaimsPrincipal to retrieve user claims
                var identity = (ClaimsPrincipal)User;

                // Extract claims
                string userId = identity.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                string userRole = identity.FindFirst(ClaimTypes.Role)?.Value;
                string userName = identity.FindFirst(ClaimTypes.Name)?.Value;

                // Check if the user has the "Admin" role
                if (userRole == "Admin" || userRole == "Staff")
                {
                    // Store user details in Session for further use
                    Session["UserId"] = userId;
                    Session["UserRole"] = userRole;
                    Session["UserName"] = userName;
                    SetPatron(userId);
                }
                else
                {
                    Response.Redirect("/error/401Unauthorized.aspx", true);
                }
            }
            else
            {
                Response.Redirect("/error/401Unauthorized.aspx", true);
                // Redirect to Login if the user is not authenticated
                //Response.Redirect("Login.aspx");
            }
        }

        private void SetPatron(string userId)
        {
            try
            {
                string patronQuery = @"SELECT PatronId
      ,EduLvl
      ,UserId
  FROM Patron
WHERE UserId = @userId
";

                if (!String.IsNullOrEmpty(Session["UserId"].ToString()))
                {
                    string userid = Session["UserId"].ToString();
                    int getPatron = Convert.ToInt32(DBHelper.ExecuteScalar(patronQuery, new string[]{
                        "userId", userId
                    }));

                    Session["PatronId"] = getPatron;


                }



            }
            catch (Exception ex)
            {

            }
        }

    }
}