using System;
using System.Collections.Generic;
using System.Data;
using System.Security.Claims;
using Microsoft.Owin.Security;
using System.Web.Security;
using System.Web;

namespace fyp
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (User.Identity.IsAuthenticated)
                {
                    // Use ClaimsPrincipal to retrieve user claims
                    var identity = (System.Security.Claims.ClaimsPrincipal)User;

                    // Extract claims from the identity
                    string userId = identity.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                    string userRole = identity.FindFirst(ClaimTypes.Role)?.Value;

                    // Redirect based on the role
                    if (userRole == "Admin" || userRole == "Staff")
                    {
                        Response.Redirect("DashManagement.aspx");
                    }
                    else
                    {
                        SetPatron(userId);
                        Response.Redirect("Home.aspx");
                    }
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUserName.Text.Trim();
            string password = txtPass.Text.Trim();

            // Validate input
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                MessageBox.Text = "Please enter both username and password.";
                return;
            }

            // Query to fetch user details
            string queryFindUser = "SELECT * FROM [User] WHERE UserName = @userName";
            string[] arrFindUser = new string[2];
            arrFindUser[0] = "@userName";
            arrFindUser[1] = username;
            DataTable dt = DBHelper.ExecuteQuery(queryFindUser, arrFindUser);

            if (dt.Rows.Count == 0)
            {
                // No matching username found
                MessageBox.Text = "Invalid Username or Password! Please Try Again.";
                return;
            }

            var userRow = dt.Rows[0];
            bool isLocked = userRow["locked"] != DBNull.Value && Convert.ToBoolean(userRow["locked"]);
            DateTime? lockDateTime = userRow["lockDateTime"] == DBNull.Value ? (DateTime?)null : Convert.ToDateTime(userRow["lockDateTime"]);

            if (isLocked && lockDateTime.HasValue)
            {
                TimeSpan lockDuration = DateTime.Now - lockDateTime.Value;
                int pendingSeconds = 5 * 60 - (int)lockDuration.TotalSeconds;

                if (pendingSeconds > 0)
                {
                    lockDurationHiddenField.Value = pendingSeconds.ToString();
                    MessageBox.Text = $"Your account is locked. It will unlock in {pendingSeconds / 60} minute(s) and {pendingSeconds % 60} second(s).";
                    return;
                }
                else
                {
                    unlockAccount(username);
                }
            }

            // Validate password
            string storedPassword = userRow["UserPassword"].ToString();
            if (encryption.IsPasswordMatch(storedPassword, password))
            {
                // Successful login
                string userRole = userRow["UserRole"].ToString();
                string userId = userRow["UserId"].ToString();

                // Set session variables
                Session["UserRole"] = userRole;
                Session["UserId"] = userId;
                Session["UserName"] = username;

                // Create claims for authentication
                var claims = new List<Claim>
                {
                    new Claim(ClaimTypes.Name, username),
                    new Claim(ClaimTypes.NameIdentifier, userId),
                    new Claim(ClaimTypes.Role, userRole)
                };
                var identity = new ClaimsIdentity(claims, "ApplicationCookie");

                // Sign in the user
                var authManager = Request.GetOwinContext().Authentication;
                if (chbRemember.Checked)
                {
                    // Persistent authentication
                    authManager.SignIn(new AuthenticationProperties
                    {
                        IsPersistent = true,                     // Persistent cookie
                        ExpiresUtc = DateTime.UtcNow.AddDays(2)  // Cookie expires in 2 days
                    }, identity);
                }
                else
                {
                    // Session-based authentication
                    authManager.SignIn(new AuthenticationProperties
                    {
                        IsPersistent = false                     // Non-persistent cookie
                    }, identity);
                }

                // Redirect based on role
                if (userRole == "Admin" || userRole == "Staff")
                {
                    Response.Redirect("DashManagement.aspx");
                }
                else
                {
                    SetPatron(userId);
                    Response.Redirect("Home.aspx");
                }
            }
            else
            {
                // Invalid password
                handleFailedLogin(username);
            }
        }

        private void handleFailedLogin(string username)
        {
            int failedAttempts = Session["invalidloginattempt"] == null ? 1 : (int)Session["invalidloginattempt"] + 1;
            Session["invalidloginattempt"] = failedAttempts;

            if (failedAttempts >= 3)
            {
                changeLockStatus(username);
                MessageBox.Text = "Your account has been locked for 5 minutes due to 3 invalid attempts.";
            }
            else
            {
                MessageBox.Text = $"Invalid Username or Password! You have {3 - failedAttempts} attempt(s) left.";
            }
        }

        private void changeLockStatus(string username)
        {
            string query = "UPDATE [User] SET locked = 1, lockDateTime = @lockDateTime WHERE UserName = @userName";
            DBHelper.ExecuteNonQuery(query, "@lockDateTime", DateTime.Now, "@userName", username);
        }

        private void unlockAccount(string username)
        {
            string query = "UPDATE [User] SET locked = 0, lockDateTime = NULL WHERE UserName = @userName";
            DBHelper.ExecuteNonQuery(query, "@userName", username);
        }

        private void SetPatron(string userId)
        {
            try
            {
                string patronQuery = "SELECT PatronId FROM Patron WHERE UserId = @userId";
                int patronId = Convert.ToInt32(DBHelper.ExecuteScalar(patronQuery, new string[] { "userId", userId }));
                Session["PatronId"] = patronId;
            }
            catch
            {
                // Ignore if no PatronId is found
            }
        }
    }
}
