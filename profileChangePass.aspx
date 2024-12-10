<%@ Page Title="profileChangePass" MasterPageFile="~/Master/Client.Master" Language="C#" AutoEventWireup="true" CodeBehind="profileChangePass.aspx.cs" Inherits="fyp.profileChangePass" %>

<asp:Content ID="content1" ContentPlaceHolderID="MainContent" runat="server">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Serif+Khitan+Small+Script&family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900&display=swap');

        /*        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: "Poppins", sans-serif;
        }*/

        .profileWraper {
            background-color: #f4f7fa;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding-top: 20px;
            padding-bottom: 20px;
            font-family: "Poppins", sans-serif;
        }

        /* Breadcrumb Navigation */
        .breadcrumb-nav {
            background-color: #e9edf3;
            padding: 10px 20px;
            border-radius: 5px;
            font-size: 16px;
            color: #6c757d;
            margin-bottom: 20px;
            width: 800px;
            text-align: left;
        }

        .navNSelected {
            color: #007bff;
            text-decoration: none;
        }

            .navNSelected:hover {
                text-decoration: underline;
            }

        .navSelected {
            color: #6c757d;
            pointer-events: none;
            text-decoration: none;
        }

        /* Profile Container */
        .profile-container {
            display: flex;
            background-color: #fff;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            width: 800px;
        }

        /* Profile Card */
        .profile-card {
            background-color: #fff;
            padding: 20px;
            width: 300px;
            text-align: center;
            border-right: 1px solid #ddd;
        }

        .profile-avatar {
            margin-top: 40px;
            width: 100px;
            height: 100px;
            border-radius: 50%;
            margin-bottom: 10px;
        }

        .profile-card h2 {
            font-size: 1.5em;
            color: #333;
            margin: 10px 0;
        }

        .profile-card p {
            color: #777;
            margin: 5px 0;
        }

        /* Profile Details */
        .profile-details {
            padding: 20px;
            flex: 1;
        }

            .profile-details h3 {
                color: #333;
                font-weight: bold;
                margin-bottom: 5px;
            }

        .input-box {
            position: relative;
            width: 100%;
            height: 50px;
            margin-bottom: 5px;
        }

            .input-box input {
                width: 100%;
                height: 100%;
                outline: none;
                border: 1px solid #ddd;
                border-radius: 5px;
                padding: 5px;
                color: #000;
            }

            .input-box i {
                position: absolute;
                right: 20px;
                top: 50%;
                transform: translateY(-50%);
                font-size: 20px;
            }

        /* Target buttons within the profile details container */
        .profile-details .update-button,
        .profile-details .cancel-button {
            display: inline-block;
            width: 150px; /* Fixed width for consistency */
            height: 50px; /* Fixed height for consistency */
            padding: 0; /* Remove padding to avoid size mismatch */
            font-size: 16px;
            font-weight: bold;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            text-align: center; /* Center text horizontally */
            line-height: 50px; /* Center text vertically */
            transition: all 0.3s ease-in-out;
        }

        /* Update Button */
        .profile-details .update-button {
            background-color: #28a745; /* Green background */
            color: #fff; /* White text */
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

            .profile-details .update-button:hover {
                background-color: #218838; /* Darker green on hover */
                box-shadow: 0 6px 8px rgba(0, 0, 0, 0.15);
            }

        /* Cancel Button */
        .profile-details .cancel-button {
            background-color: #dc3545; /* Red background */
            color: #fff; /* White text */
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

            .profile-details .cancel-button:hover {
                background-color: #c82333; /* Darker red on hover */
                box-shadow: 0 6px 8px rgba(0, 0, 0, 0.15);
            }

            /* Accessibility Focus */
            .profile-details .update-button:focus,
            .profile-details .cancel-button:focus {
                outline: 2px solid #0056b3;
                outline-offset: 2px;
            }

        .error-message {
            color: #FF6666; /* Change to #FF6666 for light red */
            font-size: 14px;
        }

        a {
            border-bottom: none !important; /* Overrides the existing border-bottom style */
        }

        p {
            text-align: center;
        }
    </style>
    <form id="form1" runat="server">
        <div class="profileWraper">
            <div class="breadcrumb-nav">
                <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="~/profile.aspx" Text="User Profile" CssClass="navNSelected" />/ 
            <asp:HyperLink ID="HyperLink2" runat="server" NavigateUrl="~/profileChangePass.aspx" Text="Change Password" CssClass="navSelected" />
            </div>

            <!-- Profile Container -->
            <div class="profile-container">
                <!-- Profile Sidebar -->
                <div class="profile-card">
                    <img src="images/user-image.jpg" alt="User Avatar" class="profile-avatar">
                </div>

                <!-- Profile Details -->
                <div class="profile-details">
                    <h3>Current Password</h3>
                    <asp:RequiredFieldValidator ID="rfvNowPass" runat="server" ControlToValidate="oldPass" ErrorMessage="*The current password is required" CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                    <div class="input-box">
                        <asp:TextBox ID="oldPass" runat="server" TextMode="Password" placeholder="Enter your current password"></asp:TextBox>
                        <i class="fa-solid fa-eye-slash" id="toggleNowPass"></i>
                    </div>
                    <asp:RegularExpressionValidator ID="revNowPass" runat="server" ControlToValidate="oldPass" ValidationExpression=".{6,}" ErrorMessage="Password must be at least 6 characters" CssClass="error-message" Display="Dynamic"></asp:RegularExpressionValidator>

                    <h3>New Password</h3>
                    <asp:RequiredFieldValidator ID="rfvNewPass" runat="server" ControlToValidate="newPass" ErrorMessage="*Password is required" CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                    <div class="input-box">
                        <asp:TextBox ID="newPass" runat="server" TextMode="Password" placeholder="Enter new password" CssClass="field"></asp:TextBox>
                        <i class="fa-solid fa-eye-slash" id="toggleNewPass"></i>
                    </div>
                    <asp:RegularExpressionValidator ID="revNewPass" runat="server" ControlToValidate="newPass" ValidationExpression=".{6,}" ErrorMessage="Password must be at least 6 characters" CssClass="error-message" Display="Dynamic"></asp:RegularExpressionValidator>

                    <h3>Re-enter Password</h3>
                    <asp:RequiredFieldValidator ID="rfvReNewPass" runat="server" ControlToValidate="reNewPass" ErrorMessage="*Please enter your confirm password" CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                    <div class="input-box">
                        <asp:TextBox ID="reNewPass" runat="server" TextMode="Password" placeholder="Confirm password" CssClass="field"></asp:TextBox>
                        <i class="fa-solid fa-eye-slash" id="toggleReNewPass"></i>
                    </div>
                    <asp:CompareValidator ID="cvPassword" runat="server" ControlToValidate="reNewPass" ControlToCompare="newPass" ErrorMessage="Passwords do not match" CssClass="error-message" Display="Dynamic"></asp:CompareValidator><br />

                    <asp:Button ID="btnUpPass" runat="server" Text="Change Password" CssClass="update-button" OnClick="btnUpPass_Click" />
                    <button type="button" class="cancel-button" onclick="resetPasswordFields()">Reset</button>
                </div>
            </div>
        </div>
    </form>
    <script>
        function resetPasswordFields() {
            // Clear the values of all password fields
            document.getElementById('<%= oldPass.ClientID %>').value = '';
            document.getElementById('<%= newPass.ClientID %>').value = '';
            document.getElementById('<%= reNewPass.ClientID %>').value = '';

            // Set focus to the oldPass field
            document.getElementById('<%= oldPass.ClientID %>').focus();
        }

        document.getElementById("toggleNowPass").addEventListener("click", function () {
            const passwordField = document.getElementById("<%= oldPass.ClientID %>");
            const type = passwordField.getAttribute("type") === "password" ? "text" : "password";
            passwordField.setAttribute("type", type);
            this.classList.toggle("fa-eye");
            this.classList.toggle("fa-eye-slash");
        });

        document.getElementById("toggleNewPass").addEventListener("click", function () {
            const passwordField1 = document.getElementById("<%= newPass.ClientID %>");
            const type = passwordField1.getAttribute("type") === "password" ? "text" : "password";
            passwordField1.setAttribute("type", type);
            this.classList.toggle("fa-eye");
            this.classList.toggle("fa-eye-slash");
        });

        document.getElementById("toggleReNewPass").addEventListener("click", function () {
            const passwordField2 = document.getElementById("<%= reNewPass.ClientID %>");
            const type = passwordField2.getAttribute("type") === "password" ? "text" : "password";
            passwordField2.setAttribute("type", type);
            this.classList.toggle("fa-eye");
            this.classList.toggle("fa-eye-slash");
        });
    </script>
</asp:Content>
