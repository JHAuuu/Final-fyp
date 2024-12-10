<%@ Page Title="changePassword" Language="C#" AutoEventWireup="true" CodeBehind="changePassword.aspx.cs" Inherits="fyp.changePassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Change Password</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@200;300;400;500;600;700&display=swap');

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: "Poppins", sans-serif;
        }

        body {
            overflow: hidden;
        }

        .container {
            display: flex;
            width: 100%;
            height: 740px;
        }

        .left,
        .right {
            width: 50%;
        }

        .left {
            background-color: black;
            display: flex;
            padding: 160px 73px;
        }

        .form-container {
            width: 100%;
            color: white;
            max-height: 600px;
            overflow-y: auto;
            padding-right: 100px;
        }

            .form-container i {
                cursor: pointer;
                font-size: 1.3rem;
                margin-left: 2px;
                margin-bottom: 10px;
                color: #fff;
            }

        h2 {
            margin-bottom: 10px;
            font-size: 30px;
        }

        p {
            font-size: 20px;
        }

        form {
            display: flex;
            flex-direction: column;
        }

        input {
            padding: 15px;
            margin: 10px 0;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            width: 100%;
        }

        #btnSPass {
            padding: 15px;
            margin-top: 30px;
            background-color: #FFD700;
            color: #111;
            border: none;
            border-radius: 5px;
            font-weight: 600;
            font-size: 18px;
            cursor: pointer;
        }

        .input-box {
            display: flex;
            align-items: center;
            height: 50px;
            width: 100%;
            margin: 10px 0;
            position: relative;
        }

            .input-box i {
                position: absolute;
                right: 10px;
                top: 50%;
                transform: translateY(-50%);
                cursor: pointer;
                padding: 15px;
                font-size: 17px;
                color: black; /* Ensure the icon is visible */
            }

            .input-box input {
                height: 100%;
                outline: none;
                border: none;
                padding: 0 40px;
                font-size: 16px;
                font-weight: 500;
                border: 1px solid #fff;
                transition: all 0.3s ease;
                background-color: #333;
                color: #fff;
            }

        input:focus {
            border-color: #7d2ae8;
        }


        label {
            margin-top: 40px;
            font-weight: 200;
        }

        input:-webkit-autofill,
        input:-webkit-autofill:focus {
            transition: background-color 0s 600000s, color 0s 600000s !important;
        }

        .error-message {
    color: red;
    font-size: 14px; /* Adjust as needed */
}
    </style>
</head>
<body>
    <div class="container">

        <div class="left">
            <div class="form-container">
                <a href="javascript:void(0);" onclick="history.back()">
                    <i class="fa-solid fa-chevron-left"></i>
                </a>
                <h2>Forgot Password</h2>
                <p>Insert your email to renew your password</p>
                <form id="forgetPasswordForm" runat="server" onsubmit="return validateForm()">
                    <!-- New Password Field -->
                    <label>Enter New Password</label>
                    <div class="input-box">
                        <asp:TextBox ID="newPass" runat="server" TextMode="Password" CssClass="input-box" placeholder="Enter new password" required="required"></asp:TextBox>
                        <i class="fa-solid fa-eye-slash" id="toggleNewPass"></i>
                    </div>
                    <div class="error-message" id="newPassError"></div>

                    <!-- Confirm Password Field -->
                    <label>Confirm Password</label>
                    <div class="input-box">
                        <asp:TextBox ID="reNewPass" runat="server" TextMode="Password" CssClass="input-box" placeholder="Retype your password" required="required"></asp:TextBox>
                        <i class="fa-solid fa-eye-slash" id="toggleReNewPass"></i>
                    </div>
                    <div class="error-message" id="reNewPassError"></div>

                    <asp:Button ID="btnSPass" runat="server" Text="Submit" OnClick="btnSPass_Click" />
                </form>
            </div>
        </div>
        <div class="right" style="background: url('images/changePass.jpeg') no-repeat; background-size: cover;"></div>
    </div>
</body>
<script>

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

    function validateForm() {
        var newPassword = document.getElementById("<%= newPass.ClientID %>").value;
        var confirmPassword = document.getElementById("<%= reNewPass.ClientID %>").value;
        var isValid = true;

        // Clear previous error messages
        document.getElementById("newPassError").innerHTML = "";
        document.getElementById("reNewPassError").innerHTML = "";

        // Validate new password (minimum 6 characters)
        if (newPassword.length < 6) {
            document.getElementById("newPassError").innerHTML = "Password must be at least 6 characters long.";
            isValid = false;
        }

        // Validate confirm password (must match new password)
        if (newPassword !== confirmPassword) {
            document.getElementById("reNewPassError").innerHTML = "Passwords do not match.";
            isValid = false;
        }

        return isValid; // Only submit the form if all validations pass
    }
</script>
</html>
