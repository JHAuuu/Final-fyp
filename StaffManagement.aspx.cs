using System;
using fyp.Authentication;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace fyp
{
    public partial class StaffManagement : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserRole"] == null)
            {
                Response.Redirect("Login.aspx");
            }
            if (Session["UserRole"]?.ToString() == "User")
            {
                Response.Redirect("Home.aspx");
            }

            var master = this.Master as DashMasterPage;
            if (master != null)
            {
                master.titleText = "Staff Management";
            }

            if (!IsPostBack)
            {
                // Check if there's a success message in the session
                if (Session["SuccessMessage"] != null)
                {
                    MessageBox.Text = Session["SuccessMessage"].ToString();
                    Session.Remove("SuccessMessage"); // Clear the message after showing it
                }
            }
        }

        [System.Web.Services.WebMethod]
        public static object CheckUserExistsAndInsertUser(string userName, string userAddress, string userEmail, string userPhoneNumber, string userPassword)
        {
            // Query to check if the username or email already exists
            string checkQuery = "SELECT UserName, UserEmail FROM [User] WHERE UserName = @UserName OR UserEmail = @UserEmail";
            string[] checkParams = { "@UserName", userName, "@UserEmail", userEmail };

            DataTable resultTable = fyp.DBHelper.ExecuteQuery(checkQuery, checkParams);

            if (resultTable.Rows.Count > 0)
            {
                // Determine if the conflict is with the username, email, or both
                string message = "";
                bool usernameExists = false;
                bool emailExists = false;

                foreach (DataRow row in resultTable.Rows)
                {
                    if (row["UserName"].ToString() == userName)
                        usernameExists = true;
                    if (row["UserEmail"].ToString() == userEmail)
                        emailExists = true;
                }

                if (usernameExists && emailExists)
                    message = "Both the username and email already exist. Please enter different values.";
                else if (usernameExists)
                    message = "The username already exists. Please enter a different one.";
                else if (emailExists)
                    message = "The email already exists. Please enter a different one.";

                return new { success = false, message };
            }
            String hashPass = encryption.HashPassword(userPassword);
            // If no conflict, proceed with inserting the new user
            string insertQuery = "INSERT INTO [User] ([UserName], [UserAddress], [UserEmail], [UserPhoneNumber], [UserPassword], [UserRole]) " +
                                 "VALUES (@UserName, @UserAddress, @UserEmail, @UserPhoneNumber, @UserPassword, @UserRole)";
            string[] insertParams = {
        "@UserName", userName,
        "@UserAddress", userAddress,
        "@UserEmail", userEmail,
        "@UserPhoneNumber", userPhoneNumber,
        "@UserPassword", hashPass,
        "@UserRole", "Staff"
    };

            int rowsAffected = fyp.DBHelper.ExecuteNonQuery(insertQuery, insertParams);

            if (rowsAffected > 0)
            {
                return new { success = true, message = "Staff registered successfully." };
            }
            else
            {
                return new { success = false, message = "An error occurred while registering the user. Please try again." };
            }
        }


        protected void GridView1_RowEditing(object sender, GridViewEditEventArgs e)
        {
            // Set the edit index to the selected row
            GridView1.EditIndex = e.NewEditIndex;

            // Re-bind the GridView to apply the current filter in edit mode
            GridView1.DataBind();
        }

        protected void GridView1_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            // Cancel edit mode
            GridView1.EditIndex = -1;

            // Re-bind the GridView to apply the current filter
            GridView1.DataBind();
        }

        protected void GridView1_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            if (Page.IsValid)
            {
                // Perform your database update logic here
                SqlDataSource1.Update();

                // Reset the edit index
                GridView1.EditIndex = -1;

                // Re-bind the GridView to reflect the updated data
                GridView1.DataBind();
            }
            else
            {
                // Handle the case where validation fails (you can log or show an error)
                Response.Write("Validation failed.");
            }
        }


    }
}