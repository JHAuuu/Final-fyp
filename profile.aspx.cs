using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Web.Security;

namespace fyp
{
    public partial class profile : UserPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                PredefinedData();
            }
        }

        private void PredefinedData()
        {

            string queryFindUser = @"SELECT 
    u.UserName, 
    u.UserEmail, 
    u.UserPhoneNumber, 
    u.UserAddress,
    u.UserRole,
    CASE 
        WHEN u.UserRole IN ('Student', 'Teacher') THEN p.EduLvl
        WHEN u.UserRole IN ('Staff', 'Admin') THEN NULL
        ELSE NULL
    END AS RoleSpecificInfo
FROM [User] u
LEFT JOIN Patron p ON u.UserId = p.UserId AND u.UserRole IN ('Student', 'Teacher')
LEFT JOIN Staff s ON u.UserId = s.UserId AND u.UserRole IN ('Staff', 'Admin')
WHERE u.UserName = @username;";
            string[] arrFindUser = new string[2];
            arrFindUser[0] = "@userName";
            arrFindUser[1] = Session["UserName"].ToString();
            DataTable dt = fyp.DBHelper.ExecuteQuery(queryFindUser, arrFindUser);
            if (dt.Rows.Count > 0) // Ensure there is a matching user
            {
                // Populate labels and textboxes with user details
                lblName.Text = dt.Rows[0]["UserName"].ToString();
                lblEmail.Text = dt.Rows[0]["UserEmail"].ToString();
                lblPhone.Text = dt.Rows[0]["UserPhoneNumber"].ToString();
                lblAddress.Text = dt.Rows[0]["UserAddress"].ToString();

                txtName.Text = dt.Rows[0]["UserName"].ToString();
                txtEmail.Text = dt.Rows[0]["UserEmail"].ToString();
                txtPhone.Text = dt.Rows[0]["UserPhoneNumber"].ToString();
                txtAddress.Text = dt.Rows[0]["UserAddress"].ToString();

                // Check the user's role
                string userRole = dt.Rows[0]["UserRole"].ToString();
                if (userRole == "Staff" || userRole == "Admin")
                {
                    // Hide the <p> element for EduLvl
                    infoEdu.Visible = false;
                }
                else
                {
                    // Show the <p> element for EduLvl and set the value
                    infoEdu.Visible = true;
                    lblEduLvl.Text = dt.Rows[0]["RoleSpecificInfo"] != DBNull.Value ? dt.Rows[0]["RoleSpecificInfo"].ToString() : "N/A";
                }
            }
            else
            {
                // Handle case where no user is found (optional)
                lblName.Text = "User not found";
            }

        }

        protected void btnUpProfile_Click(object sender, EventArgs e)
        {
            // Assuming input fields are still visible, retrieve values from them
            string name = txtName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string address = txtAddress.Text.Trim();

            string updateQuery = "UPDATE [User] SET [UserName] = @NewUserName, [UserAddress] = @UserAddress, [UserEmail] = @UserEmail, " +
                     "[UserPhoneNumber] = @UserPhoneNumber " +
                     "WHERE [UserName] = @OldUserName";

            string[] updateParams = {
                "@NewUserName", name,
                "@UserAddress", address,
                "@UserEmail", email,
                "@UserPhoneNumber", phone,
                "@OldUserName", Session["UserName"].ToString() // This is the original UserName used as the condition
            };

            int rowsAffected = fyp.DBHelper.ExecuteNonQuery(updateQuery, updateParams);

            if (rowsAffected > 0)
            {
                Session["UserName"] = name;
                // Create a new authentication ticket with the updated UserName
                FormsAuthenticationTicket newTicket = new FormsAuthenticationTicket(
                    1,
                    name, // Updated UserName
                    DateTime.Now,
                    DateTime.Now.AddMinutes(30),
                    false, // not persistent
                    Session["UserRole"].ToString() // UserRole stored in UserData
                );

                // Encrypt the ticket and update the cookie
                string encryptedTicket = FormsAuthentication.Encrypt(newTicket);
                HttpCookie authCookie = new HttpCookie(FormsAuthentication.FormsCookieName, encryptedTicket)
                {
                    HttpOnly = true,
                    Expires = newTicket.Expiration
                };
                Response.Cookies.Set(authCookie);

                // Refresh the profile data and switch back to view mode
                PredefinedData();
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", "alert('Your Profile Updated successful!!!!');", true);
                ClientScript.RegisterStartupScript(this.GetType(), "switchToViewMode", "cancelEdit();", true);
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", "alert('An error occurred while edit the profile. Please try again.');", true);
            }

        }
    }
}