<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgetPassword.aspx.cs" Inherits="fyp.ForgetPassword" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>ForgetPassword</title>
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
            background-color: #2C1A13;
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

        #btnSEmail {
            padding: 15px;
            margin-top: 30px;
            background-color: #A47D31;
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

        #btnSEmail[disabled] {
            opacity: 0.5;
            background-color: #5C514C;
            cursor: not-allowed;
        }

        #btnSEmail:hover {
          background-color: #C89A45;
          font-size: 18px;
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
                <form id="forgetPasswordForm" runat="server">

                <h2>
                    Forgot Password</h2>
                <p>Insert your email to renew your password</p>
                    <label>Email Address</label>
                    <div class="input-box">
                        <asp:TextBox ID="tBEmail" runat="server" TextMode="Email" Placeholder="Enter your email" CssClass="input-box" />
                    </div>
                    <asp:Button ID="btnSEmail" runat="server" Text="Submit" Enabled="False" OnClick="btnSEmail_Click" />
                </form>
            </div>
        </div>
        <div class="right" style="background: url('images/forPass.jpeg');"></div>
    </div>
</body>

<script>
    // Get references to ASP.NET controls using ClientID
    const emailField = document.getElementById('<%= tBEmail.ClientID %>');
    const submitBtn = document.getElementById('<%= btnSEmail.ClientID %>');

    // Email validation using regular expression
    function validateEmail() {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/; // Simple email validation regex
        return emailRegex.test(emailField.value);
    }

    // Check form validity and enable/disable the submit button accordingly
    function checkFormValidity() {
        const isEmailValid = validateEmail();
        // Enable the submit button only if the email is valid
        submitBtn.disabled = !isEmailValid;
    }

    // Add input event listener to validate the email field in real-time
    emailField.addEventListener('input', checkFormValidity);

    // Prevent form submission if the submit button is disabled
    document.getElementById("forgetPasswordForm").addEventListener("submit", function (event) {
        if (submitBtn.disabled) {
            event.preventDefault();
        }
    });
</script>
</html>
