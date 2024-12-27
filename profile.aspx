<%@ Page Title="profile" Language="C#" MasterPageFile="~/Master/Client.Master" AutoEventWireup="true" CodeBehind="profile.aspx.cs" Inherits="fyp.profile" %>

<asp:Content ID="content1" ContentPlaceHolderID="MainContent" runat="server">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Noto+Serif+Khitan+Small+Script&family=Poppins:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900&display=swap');
        /*        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: "Poppins", sans-serif;
        }*/
        .wrapContainer {
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

            .profile-details span, .profile-details input {
                display: block;
                color: #777;
                margin-bottom: 20px;
                width: 100%;
            }
        /*
        .profile-details input {
            display: none;
            padding: 5px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }*/

        form input[type="text"] {
            padding: 5px;
            border: 1px solid #ddd;
            border-radius: 5px;
        }

        a {
            border-bottom: none !important; /* Overrides the existing border-bottom style */
        }

        .profile-details a {
            color: #007bff;
            text-decoration: none;
        }

        .edit-button, .update-button, .cancel-button {
            background-color: #17a2b8;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-weight: bold;
            margin-right: 10px;
            display: inline-block;
        }

        .cancel-button {
            background-color: #dc3545; /* Red for cancel */
        }

        .update-button, .cancel-button {
            display: none;
        }
        p {
    text-align: center;
}
    </style>
    <form id="form1" runat="server">
        <div class="wrapContainer">
            <div class="breadcrumb-nav">
                <asp:HyperLink ID="HyperLink1" runat="server" NavigateUrl="~/profile.aspx" Text="User Profile" CssClass="navSelected" />/ 
            <asp:HyperLink ID="HyperLink2" runat="server" NavigateUrl="~/profileChangePass.aspx" Text="Change Password" CssClass="navNSelected" />
            </div>

            <!-- Profile Container -->
            <div class="profile-container">
                <!-- Profile Sidebar -->
                <div class="profile-card">
                     <asp:Image ID="ImageQRCode" runat="server" class="profile-avatar" alt="User Avatar"/>

                    <p>Student</p>
                    <p runat="server" id="infoEdu">Education Level : <asp:Label runat="server" ID="lblEduLvl"></asp:Label></p>
                </div>

                <!-- Profile Details -->
                <div class="profile-details">
                    <h3>Full Name</h3>
                    <asp:Label ID="lblName" runat="server" CssClass="view-text">Kenneth Valdez</asp:Label>
                    <asp:TextBox ID="txtName" runat="server" CssClass="edit-field" Style="display: none;"></asp:TextBox>

                    <h3>Email</h3>
                    <asp:Label ID="lblEmail" runat="server" CssClass="view-text">example@email.com</asp:Label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="edit-field" Style="display: none;"></asp:TextBox>

                    <h3>Phone</h3>
                    <asp:Label ID="lblPhone" runat="server" CssClass="view-text">011-55005083</asp:Label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="edit-field" Style="display: none;"></asp:TextBox>

                    <h3>Address</h3>
                    <asp:Label ID="lblAddress" runat="server" CssClass="view-text">Bay Area, San Francisco, CA</asp:Label>
                    <asp:TextBox ID="txtAddress" runat="server" CssClass="edit-field" Style="display: none;"></asp:TextBox>

                    <button type="button" class="edit-button" onclick="toggleEditMode()">Edit</button>
                    <asp:Button ID="btnUpProfile" runat="server" Text="Update" CssClass="update-button" OnClick="btnUpProfile_Click" Style="display: none;" />
                    <button type="button" class="cancel-button" onclick="cancelEdit()" style="display: none;">Cancel</button>
                </div>
            </div>
        </div>
    </form>

    <script>

        function toggleEditMode() {
            // Populate input fields with the current values from labels
            document.querySelectorAll('.view-text').forEach(label => {
                const labelId = label.id; // Get the ID of the label
                const inputId = labelId.replace('lbl', 'txt'); // Replace 'lbl' with 'txt' to match the textbox ID
                const input = document.getElementById(inputId); // Find the corresponding textbox
                if (input) {
                    input.value = label.textContent; // Set the value of the textbox to match the label's text
                }
            });

            // Hide labels and show input fields
            document.querySelectorAll('.view-text').forEach(label => label.style.display = 'none');
            document.querySelectorAll('.edit-field').forEach(input => input.style.display = 'block');

            // Toggle button visibility
            document.querySelector('.edit-button').style.display = 'none';
            document.querySelector('.update-button').style.display = 'inline-block';
            document.querySelector('.cancel-button').style.display = 'inline-block';
        }

        function cancelEdit() {
            // Show labels and hide input fields
            document.querySelectorAll('.view-text').forEach(label => label.style.display = 'block');
            document.querySelectorAll('.edit-field').forEach(input => input.style.display = 'none');

            // Toggle button visibility
            document.querySelector('.edit-button').style.display = 'inline-block';
            document.querySelector('.update-button').style.display = 'none';
            document.querySelector('.cancel-button').style.display = 'none';
        }
    </script>
        			
</asp:Content>
<asp:Content ID="content2" ContentPlaceHolderID="ScriptContent" runat="server">
    <script src="assets/js/jquery.dropotron.min.js"></script>
    <script src="assets/js/jquery.scrolly.min.js"></script>
    <script src="assets/js/jquery.scrollex.min.js"></script>
    <script src="assets/js/browser.min.js"></script>
    <script src="assets/js/breakpoints.min.js"></script>
    <script src="assets/js/util.js"></script>
    <script src="assets/js/main.js"></script>
    
</asp:Content>
