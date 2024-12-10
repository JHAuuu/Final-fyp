using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace fyp
{
    public partial class profileChangePass : UserPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            oldPass.Text = "";
            newPass.Text = "";
            reNewPass.Text = "";
            oldPass.Focus();
        }

        protected void btnUpPass_Click(object sender, EventArgs e)
        {
            string oldPassword = oldPass.Text.Trim();
            string newPassword = newPass.Text.Trim();
            String username = Session["UserName"].ToString();

            if (string.IsNullOrEmpty(oldPassword) || string.IsNullOrEmpty(newPassword))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", "alert('Please enter all password field first.');", true);
            }
            else
            {
                string queryFindUser = "SELECT * FROM [User] Where username = @userName";
                string[] arrFindUser = new string[2];
                arrFindUser[0] = "@userName";
                arrFindUser[1] = username;
                DataTable dt = fyp.DBHelper.ExecuteQuery(queryFindUser, arrFindUser);
                
                string storedPassword = dt.Rows[0]["UserPassword"].ToString();
                if (encryption.IsPasswordMatch(storedPassword, oldPassword))
                {
                    String hashPass = encryption.HashPassword(newPassword);
                    string updateQuery = "UPDATE [User] SET [UserPassword] = @UserPassword " +
                     "WHERE [UserName] = @UserName";
                    string[] insertParams = {
                        "@UserPassword", hashPass,
                        "@UserName", username,
                    };

                    int rowsAffected = fyp.DBHelper.ExecuteNonQuery(updateQuery, insertParams);

                    if (rowsAffected > 0)
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", "alert('Password changed successfully.');", true);
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", "alert('An error occurred while change the password. Please try again.');", true);
                    }
                }
                else
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", "alert('Invalid Password! Please Try Again.');", true);
                }
            }
        }
    }
}