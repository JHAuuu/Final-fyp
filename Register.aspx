<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="fyp.Register" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Register Page</title>
    <link href='https://unpkg.com/boxicons@2.1.4/css/boxicons.min.css' rel='stylesheet' />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.6.0/css/all.min.css" />
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600&display=swap');

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: "Poppins", sans-serif;
        }

        body {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            background: url("images/login.jpeg") no-repeat;
            background-size: cover;
            background-position: center;
        }

        .wrapper {
            margin-top: 80px;
            margin-bottom: 80px;
            width: 420px;
            background: transparent;
            border: 2px solid rgba(255, 255, 255, .2);
            backdrop-filter: blur(30px);
            box-shadow: 0 0 10px rgba(0, 0, 0, .2);
            color: #fff;
            border-radius: 10px;
            padding: 30px 40px;
        }

            .wrapper h1 {
                font-size: 36px;
                text-align: center;
                margin-bottom: 30px;
            }

        .input-box {
            position: relative;
            width: 100%;
            height: 50px;
            margin-bottom: 20px;
        }

            .input-box input{
                width: 100%;
                height: 100%;
                background: transparent;
                outline: none;
                border: 1px solid #ffffff;
                border-radius: 40px;
                padding: 15px 45px 15px 20px;
                color: #fff;
            }

            textarea{
                min-height:72px;
                min-width: 337px;
                max-width: 337px;
                max-height: 100px;
                background: transparent;
                outline: none;
                border: 1px solid #ffffff;
                border-radius: 40px;
                padding: 15px 45px 15px 20px;
                color: #fff;
            }

                .input-box input::placeholder, .input-box .asp-textbox::placeholder, textarea::placeholder {
                    color: #fff;
                }

            .input-box i {
                position: absolute;
                right: 20px;
                top: 50%;
                transform: translateY(-50%);
                font-size: 20px;
                color: #fff;
            }

        .wrapper .btn {
            width: 100%;
            height: 45px;
            background: #fff;
            border: none;
            outline: none;
            border-radius: 40px;
            cursor: pointer;
            font-size: 16px;
            color: #333;
            font-weight: 600;
        }

        label {
            font-weight: 600;
            font-size: 18px;
            color: #fff;
            margin-left: 10px;
        }

        .error-message {
            margin-bottom: 5px;
            color: #FFA500; /* Change to #FF6666 for light red */
            font-size: 14px;
        }

        #back {
            position: absolute;
            top: 20px;
            left: 30px;
            cursor: pointer;
            font-size: 1.3rem;
            color: #fff;
        }

        input:-webkit-autofill,
        input:-webkit-autofill:focus {
            transition: background-color 0s 600000s, color 0s 600000s !important;
        }

        .education-level-dropdown {
            width: 100%;
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 14px;
            background-color: #fff;
            color: #333;
            transition: border-color 0.3s;
        }

            /* Hover effect for dropdown */
            .education-level-dropdown:hover {
                border-color: #5cb85c;
            }

            /* Focus effect for dropdown */
            .education-level-dropdown:focus {
                border-color: #66afe9;
                outline: none;
            }
    </style>
</head>
<body>
    <a href="javascript:void(0);" onclick="history.back()">
        <i class="fa-solid fa-chevron-left" id="back">Back To Login</i>
    </a>
    <div class="wrapper">
        <form id="registerForm" runat="server" onsubmit="return validateForm()">
            <h1>Signup</h1>

            <!-- Username Field -->
            <label for="txtUserName">Username</label>
            <div class="input-box">
                <asp:TextBox ID="txtUserName" runat="server" placeholder="Enter username" CssClass="field" oninput="validateUsername()"></asp:TextBox>
                <i class='bx bx-user'></i>
            </div>
            <div id="usernameError" class="error-message" style="display:none;">*Username must be at least 5 characters long, containing only letters and spaces, and no numbers or special characters</div>

            <!-- Email Field -->
            <label for="txtEmail">Email Address</label>
            <div class="input-box">
                <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" placeholder="Enter email" CssClass="field" oninput="validateEmail()"></asp:TextBox>
                <i class='bx bx-envelope'></i>
            </div>
            <div id="emailError" class="error-message" style="display:none;">*Invalid email format. Use @student.tarc.edu.my for students register</div>
            <%--<div id="emailError" class="error-message" style="display:none;">*Invalid email format. Use @student.tarc.edu.my for students or @tarc.edu.my for teachers.</div>--%>

            <!-- Phone Number Field -->
            <label for="txtPhone">Phone Number</label>
            <div class="input-box">
                <asp:TextBox ID="txtPhone" runat="server" TextMode="Phone" placeholder="Enter phone number" CssClass="field" oninput="validatePhone()"></asp:TextBox>
                <i class='bx bx-phone'></i>
            </div>
            <div id="phoneError" class="error-message" style="display:none;">*Invalid phone number format. Must start with 01 and be 10 or 11 digits.</div>

            <label id="education-level" for="ddlEducationLevel" style="display:none;">Education Level</label>
<asp:DropDownList 
    ID="ddlEducationLevel" 
    runat="server" 
    CssClass="education-level-dropdown" 
    style="display:none;">
    <asp:ListItem Text="Diploma" Value="Diploma" />
    <asp:ListItem Text="Degree" Value="Degree" />
    <asp:ListItem Text="Master" Value="Master" />
</asp:DropDownList>


<asp:RequiredFieldValidator 
    ID="rfvEducationLevel" 
    runat="server" 
    ControlToValidate="ddlEducationLevel" 
    InitialValue="" 
    ErrorMessage="Education Level is required" 
    ForeColor="Red" 
    style="display:none;" />


            <!-- Address Field -->
            <label for="txtAddress">Address</label>
            <div class="input-box" style="margin-bottom: 60px;">
                <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" placeholder="Enter your address" CssClass="field" oninput="validateAddress()"></asp:TextBox>
                <i class='bx bx-map'></i>
            </div>
            <div id="addressError" class="error-message" style="display:none;">*Address must be between 10 and 200 characters and contain only letters, numbers, spaces, commas, periods, and hash signs.</div>

            <!-- Password Field -->
            <label for="newPass">Password</label>
            <div class="input-box">
                <asp:TextBox ID="newPass" runat="server" TextMode="Password" placeholder="Enter new password" CssClass="field" oninput="validatePassword()"></asp:TextBox>
                <i class="fa-solid fa-eye-slash" id="toggleNewPass"></i>
            </div>
            <div id="passwordError" class="error-message" style="display:none;">*Password must be at least 6 characters long.</div>

            <!-- Confirm Password Field -->
            <label for="reNewPass">Confirm Password</label>
            <div class="input-box">
                <asp:TextBox ID="reNewPass" runat="server" TextMode="Password" placeholder="Confirm password" CssClass="field" oninput="validateConfirmPassword()"></asp:TextBox>
                <i class="fa-solid fa-eye-slash" id="toggleReNewPass"></i>
            </div>
            <div id="confirmPasswordError" class="error-message" style="display:none;">*Passwords do not match.</div>

            <asp:Button ID="btnRegis" class="btn" runat="server" Text="Sign Up" OnClick="RegisterButton_Click" />
        </form>
    </div>

    <script>
        // Real-time Validation Functions

        function validateUsername() {
            const username = document.getElementById('<%= txtUserName.ClientID %>').value;
            const regex = /^[a-zA-Z\s]{5,}$/;
            const errorMessage = document.getElementById('usernameError');

            if (!regex.test(username)) {
                errorMessage.style.display = 'block';
            } else {
                errorMessage.style.display = 'none';
            }
        }

        function validatePhone() {
            const phone = document.getElementById('<%= txtPhone.ClientID %>').value;
            const regex = /^01\d{8,9}$/;
            const errorMessage = document.getElementById('phoneError');

            if (!regex.test(phone)) {
                errorMessage.style.display = 'block';
            } else {
                errorMessage.style.display = 'none';
            }
        }

        function validateAddress() {
            const address = document.getElementById('<%= txtAddress.ClientID %>').value;
            const regex = /^[a-zA-Z0-9\s,\.#\-]{10,200}$/;
            const errorMessage = document.getElementById('addressError');

            if (!regex.test(address)) {
                errorMessage.style.display = 'block';
            } else {
                errorMessage.style.display = 'none';
            }
        }

        function validatePassword() {
            const password = document.getElementById('<%= newPass.ClientID %>').value;
            const errorMessage = document.getElementById('passwordError');

            if (password.length < 6) {
                errorMessage.style.display = 'block';
            } else {
                errorMessage.style.display = 'none';
            }
        }

        function validateConfirmPassword() {
            const password = document.getElementById('<%= newPass.ClientID %>').value;
            const confirmPassword = document.getElementById('<%= reNewPass.ClientID %>').value;
            const errorMessage = document.getElementById('confirmPasswordError');

            if (password !== confirmPassword) {
                errorMessage.style.display = 'block';
            } else {
                errorMessage.style.display = 'none';
            }
        }

        function validateEmail() {
            const email = document.getElementById('<%= txtEmail.ClientID %>').value;
            const regex = /^[a-zA-Z0-9._%+-]+@(?:student\.tarc\.edu\.my|tarc\.edu\.my)$/;
            const errorMessage = document.getElementById('emailError');

            if (!regex.test(email)) {
                errorMessage.style.display = 'block';
            } else {
                errorMessage.style.display = 'none';
            }
        }

        document.getElementById("<%= txtEmail.ClientID %>").addEventListener("input", function () {
            const email = this.value.trim(); // Get the email value and remove any extra spaces
            const eduLevelLabel = document.getElementById("education-level"); // Get the label for education level
            const eduLevelDropdown = document.getElementById("<%= ddlEducationLevel.ClientID %>"); // Get the education level dropdown
            const eduLevelValidator = document.getElementById("<%= rfvEducationLevel.ClientID %>"); // Get the validator for education level

            // Check if the email ends with @student.tarc.edu.my
            if (email.endsWith("@student.tarc.edu.my")) {
                eduLevelLabel.style.display = "block"; // Show the label
                eduLevelDropdown.style.display = "block"; // Show the dropdown
                eduLevelValidator.style.display = "block"; // Show the validator
                eduLevelValidator.enabled = true; // Enable validation
            } else {
                eduLevelLabel.style.display = "none"; // Hide the label
                eduLevelDropdown.style.display = "none"; // Hide the dropdown
                eduLevelValidator.style.display = "none"; // Hide the validator
                eduLevelValidator.enabled = false; // Disable validation
                eduLevelDropdown.value = ""; // Clear the dropdown value
            }
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
</body>
</html>
