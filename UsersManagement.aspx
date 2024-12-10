<%@ Page Title="UsersManagement" Language="C#" MasterPageFile="~/Master/DashMasterPage.Master" AutoEventWireup="true" CodeBehind="UsersManagement.aspx.cs" Inherits="fyp.UsersManagement" %>

<asp:Content ID="content1" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .user-list {
            margin-top: 8px;
            background-color: #fff;
            width: 100%;
            border-collapse: collapse;
            border-radius: 5px;
            border-style: hidden;
            box-shadow: 0 0 0 2px #666;
        }

            .user-list td,
            .user-list th {
                padding: 1rem;
                font-weight: 600;
                text-align: center;
                border-bottom: 1px solid #ddd;
            }

            .user-list th {
                border-bottom: 2px solid #000000;
            }


            .user-list .action-icons a {
                text-decoration: none;
                font-size: 18px;
                margin: 0 5px;
                color: #333;
            }

        .modal {
            display: none; /* Hidden by default */
            position: fixed;
            z-index: 1000;
            padding-top: 50px;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.5);
        }

        .modal-content {
            background-color: #ffffff;
            margin: auto;
            padding: 30px;
            border-radius: 10px;
            width: 400px;
            box-shadow: 0px 5px 15px rgba(0, 0, 0, 0.3);
            position: relative;
            animation: slide-down 0.4s ease;
        }

        @keyframes slide-down {
            from {
                transform: translateY(-20px);
                opacity: 0;
            }

            to {
                transform: translateY(0);
                opacity: 1;
            }
        }


        /* Close button */
        .close {
            position: absolute;
            top: 15px;
            right: 20px;
            font-size: 24px;
            cursor: pointer;
            color: #666;
            transition: color 0.2s;
        }

            .close:hover {
                color: #333;
            }

        /* Input fields */
        .input-field {
            width: 100%;
            padding: 12px;
            margin: 10px 0;
            border: 1px solid #ddd;
            border-radius: 5px;
            box-sizing: border-box;
            font-size: 16px;
        }

            .input-field:focus {
                border-color: #007bff;
                outline: none;
                box-shadow: 0 0 5px rgba(0, 123, 255, 0.3);
            }

        /* Submit button */
        .button {
            background-color: #007bff;
            color: white;
            padding: 12px;
            margin-top: 10px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            width: 100%;
            transition: background-color 0.3s;
        }

            .button:hover {
                background-color: #0056b3;
            }


        #filter {
            padding: 3px 10px;
            font-size: 13px;
            border-radius: 5px;
        }

        .filter-btn {
            padding: 3px 10px;
            font-size: 13px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 5px;
        }

            .filter-btn:hover {
                background-color: #419544;
                transition: 300ms;
            }

        .title {
            display: flex;
            justify-content: space-between;
        }

        .add-user-button {
            padding: 5px 92px;
            font-size: 13px;
            background-color: #8390A2;
            color: white;
            border: none;
            border-radius: 5px;
        }

            .add-user-button:hover {
                background-color: #58606c;
                transition: 300ms;
            }

        .action-button {
            margin-right: 5px; /* Add a 5px gap between buttons */
            display: inline-block; /* Ensure they stay inline */
        }

        .education-level-dropdown {
            margin-bottom: 20px;
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

                    .error-message {
            color: #FFA500; /* Change to #FF6666 for light red */
            font-size: 14px;
        }
    </style>

    <h3>User list</h3>

    <div class="title">
        <asp:DropDownList ID="ddlFilter" runat="server" AutoPostBack="True" OnSelectedIndexChanged="ddlFilter_SelectedIndexChanged">
            <asp:ListItem Value="All">All Users</asp:ListItem>
            <asp:ListItem Value="Loan">Book loaning users</asp:ListItem>
            <asp:ListItem Value="Overdue">Users who loan overdue books</asp:ListItem>
            <asp:ListItem Value="Restricted">Restricted user</asp:ListItem>
        </asp:DropDownList>

        <asp:Button ID="btnAddUser" runat="server" CssClass="add-user-button" Text="Register Users" OnClientClick="showAddUserModal(); return false;" />

        <div id="addUserModal" class="modal" style="display: none;">
            <div class="modal-content">
                <span class="close" onclick="hideAddUserModal()">&times;</span>
                <h3 style="text-align: center; color: #333;">Register New User</h3>

                <asp:Label ID="lblErrorMessage" runat="server" ForeColor="Red" CssClass="error-message"></asp:Label>

                <!-- Username Field -->
                <label for="txtUserName" class="form-label">Username</label>
<asp:RequiredFieldValidator
    ID="rfvName"
    runat="server"
    ControlToValidate="txtUserName"
    ErrorMessage="*Username is required"
    CssClass="error-message"
    Display="Dynamic">
</asp:RequiredFieldValidator>
<asp:RegularExpressionValidator
    ID="revUserName"
    runat="server"
    ControlToValidate="txtUserName"
    ValidationExpression="^[a-zA-Z\s]{5,}$"
    ErrorMessage="*Username must be at least 5 characters long, containing only letters and spaces, and no numbers or special characters"
    CssClass="error-message"
    Display="Dynamic">
</asp:RegularExpressionValidator>
<div class="input-box">
    <asp:TextBox ID="txtUserName" runat="server" placeholder="Enter username" CssClass="input-field"></asp:TextBox>
    <i class='bx bx-user'></i>
</div>

                <!-- Address Field -->
                <label for="txtAddress" class="form-label">Address</label>
                <asp:RequiredFieldValidator ID="rfvAddress" runat="server" ControlToValidate="txtAddress" ErrorMessage="*Address is required" CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator><br />
                <div class="input-box">
                    <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" placeholder="Enter your address" CssClass="input-field"></asp:TextBox>
                    <i class='bx bx-map'></i>
                </div>

                <br />
                <!-- Email Field -->
                <label for="txtEmail" class="form-label">Email Address</label><asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="txtEmail" ErrorMessage="*Email is required" CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                <div class="input-box">
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" placeholder="Enter email" CssClass="input-field"></asp:TextBox>
                    <i class='bx bx-envelope'></i>
                </div>
                <asp:RegularExpressionValidator
                    ID="revEmail"
                    runat="server"
                    ControlToValidate="txtEmail"
                    ValidationExpression="^[^\s@]+@(student\.tarc\.edu\.my|tarc\.edu\.my)$"
                    ErrorMessage="Invalid email format. Use @student.tarc.edu.my for students or @tarc.edu.my for teachers."
                    CssClass="error-message"
                    Display="Dynamic" /><br />

                <!-- Education Level Field -->
                <label class="education-level" id="lblEducationLevel" style="display: none;">Education Level</label>
                <asp:RequiredFieldValidator
                    ID="rfvEducationLevel"
                    runat="server"
                    ControlToValidate="ddlEducationLevel"
                    InitialValue=""
                    ErrorMessage="*Please select an education level"
                    CssClass="error-message"
                    Display="Dynamic"
                    Style="display: none;" />
                <br />
                <asp:DropDownList
                    ID="ddlEducationLevel"
                    runat="server"
                    CssClass="education-level-dropdown"
                    Style="display: none;">
                    <asp:ListItem Text="Diploma" Value="Diploma" />
                    <asp:ListItem Text="Degree" Value="Degree" />
                    <asp:ListItem Text="Master" Value="Master" />
                </asp:DropDownList>

                <!-- Phone Number Field -->
                <label for="txtPhone" class="form-label">Phone Number</label>
                <asp:RequiredFieldValidator ID="rfvPhone" runat="server" ControlToValidate="txtPhone" ErrorMessage="*Phone number is required" CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                <div class="input-box">
                    <asp:TextBox ID="txtPhone" runat="server" TextMode="Phone" placeholder="Enter phone number" CssClass="input-field"></asp:TextBox>
                    <i class='bx bx-phone'></i>
                </div>
                <asp:RegularExpressionValidator ID="revPhone" runat="server" ControlToValidate="txtPhone"
                    ValidationExpression="^(01[0-9]{8,9})$" ErrorMessage="Invalid phone number format. Must start with 01 and be 10 or 11 digits."
                    CssClass="error-message" Display="Dynamic" /><br />

                <!-- Password Field -->
                <label for="newPass" class="form-label">Password</label>
                <asp:RequiredFieldValidator ID="rfvNewPass" runat="server" ControlToValidate="txtUserPassword" ErrorMessage="*Password is required" CssClass="error-message" Display="Dynamic"></asp:RequiredFieldValidator>
                <div class="input-box">
                    <asp:TextBox ID="txtUserPassword" runat="server" TextMode="Password" placeholder="Enter new password" CssClass="input-field"></asp:TextBox>
                    <i class="fa-solid fa-eye-slash" id="toggleNewPass"></i>
                </div>
                <asp:RegularExpressionValidator ID="revNewPass" runat="server" ControlToValidate="txtUserPassword" ValidationExpression=".{6,}" ErrorMessage="Password must be at least 6 characters" CssClass="error-message" Display="Dynamic"></asp:RegularExpressionValidator><br />

                <asp:Button ID="btnSubmitUser" runat="server" Text="Submit" CssClass="button" UseSubmitBehavior="false" OnClick="btnSubmitUser_Click" />
            </div>
        </div>
    </div>
    <asp:Label ID="MessageBox" runat="server" ForeColor="Red"></asp:Label>
    <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" SelectCommand="SELECT [UserId], [UserName], [UserAddress], [UserEmail], [UserPhoneNumber] FROM [User] WHERE ([UserRole] IN ('Student', 'Teacher') AND [IsDeleted] = 0)" UpdateCommand="UPDATE [User]
SET 
    [UserName] = @UserName,
    [UserAddress] = @UserAddress,
    [UserEmail] = @UserEmail,
    [UserPhoneNumber] = @UserPhoneNumber
WHERE 
    [UserId] = @UserId;">
        <UpdateParameters>
            <asp:Parameter Name="UserName" />
            <asp:Parameter Name="UserAddress" />
            <asp:Parameter Name="UserEmail" />
            <asp:Parameter Name="UserPhoneNumber" />
            <asp:Parameter Name="UserId" />
        </UpdateParameters>
    </asp:SqlDataSource>

    <asp:GridView ID="GridView1" runat="server" OnRowEditing="GridView1_RowEditing"
        OnRowCancelingEdit="GridView1_RowCancelingEdit"
        OnRowCommand="GridView1_RowCommand" OnRowUpdating="GridView1_RowUpdating" AllowPaging="True" AllowSorting="True" AutoGenerateColumns="False"
        CssClass="user-list" CellPadding="4" DataSourceID="SqlDataSource1" DataKeyNames="UserId" ForeColor="#8390A2">
        <Columns>
            <asp:BoundField DataField="UserId" HeaderText="UserId" SortExpression="UserId" ReadOnly="True" />
            <asp:TemplateField HeaderText="Name">
                <ItemTemplate>
                    <asp:Label ID="lblUserName" runat="server" Text='<%# Eval("UserName") %>' />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtUserName" runat="server" Text='<%# Bind("UserName") %>' CssClass="input-field" />
                    <asp:RequiredFieldValidator ID="rfvUserName" runat="server" ControlToValidate="txtUserName"
                        ErrorMessage="Name is required." CssClass="error-message" Display="Dynamic" ValidationGroup="UserUpdate" />
                    <asp:RegularExpressionValidator
                        ID="revUserName"
                        runat="server"
                        ControlToValidate="txtUserName"
                        ValidationExpression="^[a-zA-Z\s]{5,}$"
                        ErrorMessage="Name must be at least 5 characters and contain only letters and spaces."
                        CssClass="error-message"
                        Display="Dynamic"
                        ValidationGroup="UserUpdate" />
                </EditItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Address">
                <ItemTemplate>
                    <asp:Label ID="lblUserAddress" runat="server" Text='<%# Eval("UserAddress") %>' />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtUserAddress" runat="server" Text='<%# Bind("UserAddress") %>' CssClass="input-field" />
                    <asp:RequiredFieldValidator ID="rfvUserAddress" runat="server" ControlToValidate="txtUserAddress"
                        ErrorMessage="Address is required." CssClass="error-message" Display="Dynamic" ValidationGroup="UserUpdate" />
                    <asp:RegularExpressionValidator
                        ID="revUserAddress"
                        runat="server"
                        ControlToValidate="txtUserAddress"
                        ValidationExpression="^[a-zA-Z0-9\s,\.#\-]{10,200}$"
                        ErrorMessage="Address must be between 10 and 200 characters and may only contain letters, numbers, spaces, commas, periods, '#', and hyphens."
                        CssClass="error-message"
                        Display="Dynamic"
                        ValidationGroup="UserUpdate" />
                </EditItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Email">
                <ItemTemplate>
                    <asp:Label ID="lblUserEmail" runat="server" Text='<%# Eval("UserEmail") %>' />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtUserEmail" runat="server" Text='<%# Bind("UserEmail") %>' CssClass="input-field" />
                    <asp:RequiredFieldValidator ID="rfvUserEmail" runat="server" ControlToValidate="txtUserEmail"
                        ErrorMessage="Email is required." CssClass="error-message" Display="Dynamic" ValidationGroup="UserUpdate" />
                    <asp:RegularExpressionValidator ID="revUserEmail" runat="server" ControlToValidate="txtUserEmail"
                        ValidationExpression="^[a-zA-Z0-9._%+-]+@(?:student\.tarc\.edu\.my|tarc\.edu\.my)$" ErrorMessage="Invalid email format."
                        CssClass="error-message" Display="Dynamic" ValidationGroup="UserUpdate" />
                </EditItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Phone Number">
                <ItemTemplate>
                    <asp:Label ID="lblUserPhoneNumber" runat="server" Text='<%# Eval("UserPhoneNumber") %>' />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtUserPhoneNumber" runat="server" Text='<%# Bind("UserPhoneNumber") %>' CssClass="input-field" />
                    <asp:RequiredFieldValidator ID="rfvUserPhoneNumber" runat="server" ControlToValidate="txtUserPhoneNumber"
                        ErrorMessage="Phone number is required." CssClass="error-message" Display="Dynamic" ValidationGroup="UserUpdate" />
                    <asp:RegularExpressionValidator ID="revUserPhoneNumber" runat="server" ControlToValidate="txtUserPhoneNumber"
                        ValidationExpression="^01\d{8,9}$" ErrorMessage="Phone number must be 10-11 digits."
                        CssClass="error-message" Display="Dynamic" ValidationGroup="UserUpdate"/>
                </EditItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Barcode">
                <ItemTemplate>
                    <asp:Button ID="btnDownloadBarcode" runat="server" Text="Download User's QRcode" CssClass="barcode-button"
                        CommandName="DownloadBarcode" CommandArgument='<%# Eval("UserId") %>' CausesValidation="false" />
                </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Action">
                <ItemTemplate>
                    <asp:LinkButton ID="EditButton" runat="server" CommandName="Edit" CssClass="action-button" CausesValidation="false">
                    <i class="las la-user-edit"></i>
                    </asp:LinkButton>
                    <a href="javascript:void(0);" onclick="window.location.href='UserHistory.aspx?UserId=<%# Eval("UserId") %>'" class="action-button">
                        <i class="las la-history"></i>
                    </a>
                    <a href="javascript:void(0);" onclick="showInboxModal('<%# Eval("UserId") %>')" class="action-button">
                        <i class="las la-inbox"></i>
                    </a>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:LinkButton ID="UpdateButton" runat="server" CommandName="Update" Text="Update" CssClass="button" CausesValidation="true" ValidationGroup="UserUpdate" />
                    <asp:LinkButton ID="CancelButton" runat="server" CommandName="Cancel" Text="Cancel" CssClass="button" CausesValidation="false" />
                </EditItemTemplate>
            </asp:TemplateField>
        </Columns>
        <HeaderStyle ForeColor="Black" />
    </asp:GridView>
<div id="inboxModal" class="modal" style="display: none;">
        <div class="modal-content">
            <span class="close" onclick="hideInboxModal()">&times;</span>
            <h3 style="margin-bottom: 30px; text-align: center; color: #333;">Send Inbox Message</h3>
            <asp:Label ID="lblInboxErrorMessage" runat="server" ForeColor="Red" CssClass="error-message"></asp:Label>
            <asp:Label ID="lblInboxTitleLabel" runat="server" Text="Inbox Title:" AssociatedControlID="txtInboxTitle" CssClass="field-label" Style="font-weight: bold; color: #555;"></asp:Label>
            <asp:TextBox ID="txtInboxTitle" runat="server" Placeholder="Inbox Title" CssClass="input-field" /><br />
            <asp:Label ID="lblInboxContentLabel" runat="server" Text="Inbox Content:" AssociatedControlID="txtInboxContent" CssClass="field-label" Style="font-weight: bold; color: #555;"></asp:Label>
            <asp:TextBox ID="txtInboxContent" runat="server" Placeholder="Inbox Content" CssClass="input-field" TextMode="MultiLine" Rows="4" /><br />
            <asp:Button ID="btnSendInbox" runat="server" Text="Send" CssClass="button" UseSubmitBehavior="false" OnClientClick="validateAndSendInbox(); return false;" />
        </div>
    </div>
    <asp:HiddenField ID="hfUserId" runat="server" />
    <script>
        document.getElementById("<%= txtEmail.ClientID %>").addEventListener("input", function () {
            const email = this.value.trim();
            const eduLevelLabel = document.getElementById("lblEducationLevel");
            const eduLevelDropdown = document.getElementById("<%= ddlEducationLevel.ClientID %>");
            const eduLevelValidator = document.getElementById("<%= rfvEducationLevel.ClientID %>");

            // Check if email belongs to a student
            if (email.endsWith("@student.tarc.edu.my")) {
                // Show the education level fields
                eduLevelLabel.style.display = "block";
                eduLevelDropdown.style.display = "block";
                eduLevelValidator.style.display = "block";
                eduLevelValidator.enabled = true; // Enable validator for students
            } else {
                // Hide the education level fields
                eduLevelLabel.style.display = "none";
                eduLevelDropdown.style.display = "none";
                eduLevelValidator.style.display = "none";
                eduLevelValidator.enabled = false; // Disable validator for teachers

                // Clear any selected value in the dropdown
                eduLevelDropdown.value = "";
            }
        });

        // Show the inbox modal with the userId parameter
        function showInboxModal(userId) {
            console.log("Modal triggered with UserId:", userId);
            document.getElementById('inboxModal').style.display = 'block';
            document.getElementById('<%= hfUserId.ClientID %>').value = userId; // Store the userId for later submission
        }

        // Hide the inbox modal
        function hideInboxModal() {
            const inboxTitle = document.getElementById('<%= txtInboxTitle.ClientID %>');
                    const inboxContent = document.getElementById('<%= txtInboxContent.ClientID %>');
                    const errorMessage = document.getElementById('<%= lblInboxErrorMessage.ClientID %>');
                    document.getElementById('inboxModal').style.display = 'none';
                    inboxTitle.value = "";
                    inboxContent.value = "";
                    errorMessage.innerText = "";
        }


        // Validate and submit the inbox message
        function validateAndSendInbox() {
            const inboxTitle = document.getElementById('<%= txtInboxTitle.ClientID %>').value;
            const inboxContent = document.getElementById('<%= txtInboxContent.ClientID %>').value;

            // Validate fields
            if (!inboxTitle || !inboxContent) {
                document.getElementById('<%= lblInboxErrorMessage.ClientID %>').innerText = "Both title and content are required.";
                return;
            }

            // Call backend method to insert the message
            fetch('UsersManagement.aspx/SendInboxMessage', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    userId: document.getElementById('<%= hfUserId.ClientID %>').value,
                    inboxTitle: inboxTitle,
                    inboxContent: inboxContent
                })
            })
                .then(response => response.json())
                .then(data => {
                    if (data.d.Success) {
                        document.getElementById('<%= lblInboxErrorMessage.ClientID %>').innerText = "";
                        inboxTitle.value = "";
                        inboxContent.value = "";
                        alert(data.d.Message); // Use 'data.d.Message' as the success message
                        hideInboxModal();
                    } else {
                        // Display error message
                        document.getElementById('<%= lblInboxErrorMessage.ClientID %>').innerText = data.d.Message;
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                    // Display the error in lblInboxErrorMessage
                    document.getElementById('<%= lblInboxErrorMessage.ClientID %>').innerText = "An unexpected error occurred. Please try again.";
                });
        }


        //register user button action
        function showAddUserModal() {
            document.getElementById('addUserModal').style.display = 'block';
        }

        function hideAddUserModal() {
            document.getElementById('addUserModal').style.display = 'none';
        }

        function validateAndSubmitUser() {
            const userName = document.getElementById('<%= txtUserName.ClientID %>').value;
            const userAddress = document.getElementById('<%= txtAddress.ClientID %>').value;
            const userEmail = document.getElementById('<%= txtEmail.ClientID %>').value;
            const userPhoneNumber = document.getElementById('<%= txtPhone.ClientID %>').value;
            const userPassword = document.getElementById('<%= txtUserPassword.ClientID %>').value;
            // Get the value of the education level dropdown
            const educationLevel = educationLevelDropdown.style.display === "none" ? null : educationLevelDropdown.value;

            fetch('UsersManagement.aspx/CheckUserExistsAndInsertUser', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    userName: userName,
                    userAddress: userAddress,
                    userEmail: userEmail,
                    educationLevel: educationLevel,
                    userPhoneNumber: userPhoneNumber,
                    userPassword: userPassword
                })
            })
                .then(response => response.json())
                .then(data => {
                    if (data.d.success) {
                        // Display success message or reload the page
                        alert(data.d.message);
                        location.reload();
                    } else {
                        // Display the error message in the modal
                        document.getElementById('<%= lblErrorMessage.ClientID %>').innerText = data.d.message;
                    }
                })
                .catch(error => {
                    console.error('Error:', error);
                });
        }


    </script>
</asp:Content>


