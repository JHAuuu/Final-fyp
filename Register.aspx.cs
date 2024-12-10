using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace fyp
{
    public partial class Register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                txtUserName.Text = "";
                txtEmail.Text = "";
                txtPhone.Text = "";
                txtAddress.Text = "";
                ddlEducationLevel.SelectedIndex = 0;  // Clear the dropdown (or set to a default value)
                newPass.Text = "";
                reNewPass.Text = "";
                txtUserName.Focus();
            }
        }

        protected void RegisterButton_Click(object sender, EventArgs e)
        {
            string UserName = txtUserName.Text.Trim();
            string UserEmail = txtEmail.Text.Trim();
            string UserPhoneNumber = txtPhone.Text.Trim();
            string UserAddress = txtAddress.Text.Trim();
            string EduLvl = ddlEducationLevel.SelectedValue; // Will be empty for teachers
            string userPassword = newPass.Text.Trim();

            string UserPassword = encryption.HashPassword(userPassword);

            try
            {
                // Determine user role based on email domain
                string UserRole = UserEmail.EndsWith("@student.tarc.edu.my") ? "Student" :
                                  UserEmail.EndsWith("@tarc.edu.my") ? "Teacher" : null;

                if (UserRole == null)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", "alert('Invalid email domain.');", true);
                    return;
                }

                int initialTrustScore = UserRole == "Student" ? 100 : 120;
                string initialTrustLvl = UserRole == "Student" ? "High" : "Very High";

                // Check if username or email already exists
                string queryFindUser = "SELECT COUNT(*) FROM [User] WHERE UserName = @UserName OR UserEmail = @UserEmail";
                string[] arrFindUser = new string[4];
                arrFindUser[0] = "@UserName";
                arrFindUser[1] = UserName;
                arrFindUser[2] = "@UserEmail";
                arrFindUser[3] = UserEmail;

                DataTable dt = DBHelper.ExecuteQuery(queryFindUser, arrFindUser);

                if (dt.Rows.Count > 0 && Convert.ToInt32(dt.Rows[0][0]) > 0)
                {
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", "alert('Username or Email already exists!');", true);
                }
                else
                {
                    // Insert into [User] table
                    string insertUserQuery = "INSERT INTO [User] (UserName, UserEmail, UserPhoneNumber, UserAddress, UserPassword, UserRole) " +
                                             "VALUES (@UserName, @UserEmail, @UserPhoneNumber, @UserAddress, @UserPassword, @UserRole); " +
                                             "SELECT SCOPE_IDENTITY();";

                    string[] arrInsertUser = new string[12];
                    arrInsertUser[0] = "@UserName";
                    arrInsertUser[1] = UserName;
                    arrInsertUser[2] = "@UserEmail";
                    arrInsertUser[3] = UserEmail;
                    arrInsertUser[4] = "@UserPhoneNumber";
                    arrInsertUser[5] = UserPhoneNumber;
                    arrInsertUser[6] = "@UserAddress";
                    arrInsertUser[7] = UserAddress;
                    arrInsertUser[8] = "@UserPassword";
                    arrInsertUser[9] = UserPassword;
                    arrInsertUser[10] = "@UserRole";
                    arrInsertUser[11] = UserRole;

                    object result = DBHelper.ExecuteScalar(insertUserQuery, arrInsertUser);

                    if (result != null)
                    {
                        int userId = Convert.ToInt32(result);

                        // Insert into Patron table
                        string insertPatronQuery = "INSERT INTO Patron (EduLvl, UserId) VALUES (@EduLvl, @UserId); SELECT SCOPE_IDENTITY();";

                        object eduLevelParam;
                        if (UserRole == "Student")
                        {
                            eduLevelParam = EduLvl; // Assign EduLvl for students
                        }
                        else
                        {
                            eduLevelParam = DBNull.Value; // Assign DBNull.Value for teachers
                        }

                        object[] arrInsertPatron = new object[4];
                        arrInsertPatron[0] = "@EduLvl";
                        arrInsertPatron[1] = eduLevelParam;
                        arrInsertPatron[2] = "@UserId";
                        arrInsertPatron[3] = userId;

                        object patronResult = DBHelper.ExecuteScalar(insertPatronQuery, arrInsertPatron);

                        if (patronResult != null)
                        {
                            int patronId = Convert.ToInt32(patronResult);

                            // Insert Trustworthy data
                            InsertTrustworthyData(patronId, initialTrustScore, initialTrustLvl);

                            // Registration successful
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", "alert('Registration successful!'); window.location='Login.aspx';", true);
                        }
                        else
                        {
                            ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", "alert('Error occurred while registering Patron data.');", true);
                        }
                    }
                    else
                    {
                        ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", "alert('Error occurred while registering user.');", true);
                    }
                }
            }
            catch (Exception ex)
            {
                string alertMessage = "Error: " + ex.Message;
                ScriptManager.RegisterStartupScript(this, this.GetType(), "showalert", "alert('" + alertMessage.Replace("'", "\\'") + "');", true);
            }
        }

        private void InsertTrustworthyData(int patronId, int trustScore, string trustLvl)
        {
            string insertTrustQuery = "INSERT INTO Trustworthy (TrustScore, TrustLvl, PatronId) VALUES (@TrustScore, @TrustLvl, @PatronId)";
            string[] arrInsertTrust = new string[6];
            arrInsertTrust[0] = "@TrustScore";
            arrInsertTrust[1] = trustScore.ToString();
            arrInsertTrust[2] = "@TrustLvl";
            arrInsertTrust[3] = trustLvl;
            arrInsertTrust[4] = "@PatronId";
            arrInsertTrust[5] = patronId.ToString();

            int trustRowsAffected = DBHelper.ExecuteNonQuery(insertTrustQuery, arrInsertTrust);

            if (trustRowsAffected <= 0)
            {
                throw new Exception("Error occurred while saving Trust data.");
            }
        }





    }
}