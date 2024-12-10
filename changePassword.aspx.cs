using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace fyp
{
    public partial class changePassword : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Retrieve the email from the query string
            string email = Request.QueryString["email"];

            if (!string.IsNullOrEmpty(email))
            {
                // Validate the reset link's expiry time and if it's been used
                if (!IsValidResetLink(email))
                {
                    // Invalid or expired link, inform the user and stop rendering the form
                    ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('The password reset link has expired or has already been used.');", true);
                    Response.Redirect("LinkExpired.aspx");
                    return;
                }
            }
            else
            {
                // Invalid email in the query string
                ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Invalid email address.');", true);
                Response.Redirect("InvalidRequest.aspx");
            }
        }

        private bool IsValidResetLink(string email)
        {
            string query = "SELECT ResetExpiryTime, IsResetUsed FROM [User] WHERE UserEmail = @UserEmail";
            object[] parameters = { "@UserEmail", email };
            DataTable result = DBHelper.ExecuteQuery(query, parameters);

            if (result.Rows.Count > 0)
            {
                // Access the first row
                DataRow row = result.Rows[0];
                // Handle ResetExpiryTime
                DateTime? resetExpiryTime = row["ResetExpiryTime"] != DBNull.Value
                    ? Convert.ToDateTime(row["ResetExpiryTime"])
                    : (DateTime?)null;

                // Handle IsResetUsed
                bool isResetUsed = row["IsResetUsed"] != DBNull.Value && Convert.ToBoolean(row["IsResetUsed"]);


                // Check if ResetExpiryTime is null or link has expired or reset is already used
                if (!resetExpiryTime.HasValue || DateTime.Now > resetExpiryTime.Value || isResetUsed)
                {
                    return false; // Link expired, already used, or invalid
                }
            }
            else
            {
                // If no rows are returned, the email doesn't exist in the database or the query failed
                return false;
            }

            return true; // Valid reset link
        }
        protected void btnSPass_Click(object sender, EventArgs e)
        {
            string UserEmail = Request.QueryString["email"];
            string newPassword = newPass.Text;

            try
            {
                if (string.IsNullOrEmpty(newPassword))
                {
                    ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Please provide a valid password.');", true);
                    return;
                }
                else
                {
                    // Hash the new password
                    string hashedPassword = encryption.HashPassword(newPassword);

                    // Update the password in the database
                    string updateQuery = "UPDATE [User] SET [UserPassword] = @UserPassword, IsResetUsed = 1 WHERE [UserEmail] = @UserEmail";
                    object[] updateParams = {
                        "@UserPassword", hashedPassword,
                        "@UserEmail", UserEmail
                    };

                    int rowsAffected = fyp.DBHelper.ExecuteNonQuery(updateQuery, updateParams);

                    // If the update is successful, notify the user
                    if (rowsAffected > 0)
                    {
                        ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('Password has been successfully updated.');", true);
                        Response.Redirect("Login.aspx");
                    }
                    else
                    {
                        ClientScript.RegisterStartupScript(this.GetType(), "alert", "alert('There was an error updating the password. Please try again.');", true);
                    }
                }
            }
            catch (Exception ex)
            {
                ClientScript.RegisterStartupScript(this.GetType(), "alert", $"alert('An error occurred: {ex.Message}');", true);
            }
        }



    }
}