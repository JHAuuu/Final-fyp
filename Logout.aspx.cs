using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.Security;

namespace fyp
{
    public partial class Logout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Clear the session
            Session.Clear();
            Session.Abandon();

            // Perform OWIN SignOut
            var authManager = Request.GetOwinContext().Authentication;
            authManager.SignOut("ApplicationCookie");

            // Redirect to the login page
            Response.Redirect("Login.aspx");
        }
    }
}