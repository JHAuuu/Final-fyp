<%@ Page Title="AnnouncementManagement" MasterPageFile="~/Master/DashMasterPage.Master" Language="C#" AutoEventWireup="true" CodeBehind="AnnouncementManagement.aspx.cs" Inherits="fyp.AnnouncementManagement" %>

<asp:Content ID="content1" ContentPlaceHolderID="MainContent" runat="server">
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

    <style>

        /* Search Bar Styling */
        .search-container {
    text-align: center;
    margin: 5px 0;
}

.searchBar {
    padding: 10px;
    font-size: 16px;
    width: 300px;
    border: 1px solid #ccc;
    border-radius: 5px 0 0 5px;
    margin-right: -4px;
}

    .btnSearch {
    padding: 10px 15px;
    font-size: 16px;
    background-color: #4CAF50;
    color: white;
    border: 1px solid #4CAF50;
    border-radius: 0 5px 5px 0;
    cursor: pointer;
    background-image: url('Image/searchIcon.png'); /* Path to your image */
    background-repeat: no-repeat;
    background-position: center; /* Adjust position as needed */
    padding-left: 35px; /* Adjust padding to make space for the image */
}

        .push-announcement-button {
            margin-left:20px;
            padding: 10px 20px;
            font-size: 16px;
            background-color: #007BFF;
            color: white;
            border: 1px solid #007BFF;
            border-radius: 5px;
            /* Rounded corners */
            cursor: pointer;
        }

        /* Announcement Container and Items */
        .announcement-container {
            width: 100%;
            max-width: 800px;
            margin: 20px auto;
            font-family: Arial, sans-serif;
        }

        .announcement-item {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid #e0e0e0;
        }

            .announcement-item .date {
                min-width: 10%;
                text-align: right;
                padding-right: 20px;
                color: #888;
            }

                .announcement-item .date .day {
                    font-weight: bold;
                    display: block;
                }

                .announcement-item .date .time,
                .announcement-item .date .year {
                    font-size: 12px;
                    display: block;
                }

        .separator {
            width: 2px;
            height: 40px;
            background-color: #ccc;
            margin: 0 15px;
        }

        .announcement-item .content {
            flex: 1;
        }

            .announcement-item .content h3 {
                margin: 0;
                font-size: 18px;
                color: #333;
                flex: 1;
                /* Allow the text to take up available space */
            }

            .announcement-item .content p {
                margin: 5px 0 0;
                color: #555;
                font-size: 14px;
                flex: 1;
                /* Allow the text to take up available space */
            }

        /* Edit and Delete Buttons */
        .text-and-buttons {
            display: flex;
            justify-content: space-between;
            align-items: center;
            width: 100%;
        }

        /* Ensure text container takes remaining space */
        .text {
            flex: 1;
            margin-right: 20px;
        }

        /* Fixed width for button container to prevent shifting */
        .buttons {
            display: flex;
            gap: 10px;
            min-width: 150px; /* Adjust as needed to ensure consistent alignment */
        }

        /* Style for the buttons */
        .edit-button,
        .delete-button {
            padding: 5px 10px;
            font-size: 14px;
            color: white;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            white-space: nowrap; /* Prevents wrapping of button text */
        }

        .edit-button {
            background-color: #007BFF; /* Blue */
        }

        .delete-button {
            background-color: #DC3545; /* Red */
        }

        /* Basic modal overlay */
        .modal-edit, .modal-push {
            display: flex; /* Use flexbox to center the modal */
            justify-content: center; /* Center horizontally */
            align-items: center; /* Center vertically */
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-color: rgba(0, 0, 0, 0.5);
            z-index: 1000;
        }

        /* Modal container */
        .modal {
            background-color: white;
            width: 500px;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
            position: relative;
            display: flex;
            flex-direction: column;
        }

        /* Modal header */
        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }

        .modal-title {
            font-size: 18px;
            font-weight: bold;
            color: #333;
        }

        .modal-body label {
            display: block;
            text-align: left;
            font-weight: bold; /* Optional: Makes the label stand out */
        }

        .close {
            font-size: 20px;
            cursor: pointer;
            color: #aaa;
        }

        .close:hover {
            color: #333;
        }

        /* Modal body */
        .modal-body {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .form-control {
            width: 100%;
            padding: 10px;
            font-size: 14px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }

        /* Modal footer */
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 10px;
        }

        .btn {
            padding: 8px 15px;
            font-size: 14px;
            cursor: pointer;
            border: none;
            border-radius: 4px;
            color: white;
            font-weight: bold;
        }

        .btn-primary {
            background-color: #007BFF;
        }

        .btn-secondary {
            background-color: #6c757d;
        }

        .btn-primary:hover {
            background-color: #0056b3;
        }

        .btn-secondary:hover {
            background-color: #5a6268;
        }

        .last-updated {
    display: block;
    color: #555;
    font-size: 12px;
    margin-top: 10px;
}

.modified-status {
    display: block;
    color: #FF8C00; /* Orange for modified status */
    font-size: 12px;
    margin-top: 5px;
}
    </style>
    <div class="search-container">
        <asp:TextBox ID="searchBar" placeholder="Search announcements..." CssClass="searchBar" runat="server"></asp:TextBox>
        <asp:Button ID="btnSearch" runat="server" CssClass="btnSearch" Text="" OnClick="btnSearch_Click" />
        <asp:Button ID="btnPushAnnouncement" runat="server" CssClass="push-announcement-button" Text="Push Announcement" />
        <div class="modal-push" id="newAnnouncementModal" style="display: none;">
            <div class="modal">
                <div class="modal-header">
                    <span class="modal-title">New Announcement</span>
                    <span class="close" onclick="closeNewModal()">&times;</span>
                </div>
                <div class="modal-body">
                    <label for="NewTitle">Title</label>
                    <asp:TextBox ID="NewTitle" runat="server" CssClass="form-control" Placeholder="Title"></asp:TextBox>
                    <label for="NewContent">Content</label>
                    <asp:TextBox ID="NewContent" runat="server" CssClass="form-control" TextMode="MultiLine" Placeholder="Content"></asp:TextBox>
                </div>
                <div class="modal-footer">
                    <asp:Button ID="SaveNewButton" runat="server" CssClass="btn btn-primary" Text="Save" OnClick="pushAnnouncement_Click" />
                    <button type="button" class="btn btn-secondary" onclick="closeNewModal()">Close</button>
                </div>
            </div>
        </div>
    </div>
    <asp:SqlDataSource 
    ID="SqlDSourceDisplay" 
    runat="server" 
    ConnectionString="<%$ ConnectionStrings:ConnectionString %>" 
    SelectCommand="SELECT * FROM [Announcement] ORDER BY [DateTime] DESC" 
    DeleteCommand="DELETE FROM [Announcement] WHERE AnnouncementId = @AnnouncementId" 
    UpdateCommand="UPDATE [Announcement] SET Title = @Title, Content = @Content WHERE AnnouncementId = @AnnouncementId">
    
    <DeleteParameters>
        <asp:Parameter Name="AnnouncementId" Type="Int32" />
    </DeleteParameters>
    
    <UpdateParameters>
        <asp:Parameter Name="Title" />
        <asp:Parameter Name="Content" />
        <asp:Parameter Name="AnnouncementId" />
    </UpdateParameters>
</asp:SqlDataSource>
    <div class="announcement-container">
        <asp:Repeater ID="RepeaterAnnouncements" runat="server" DataSourceID="SqlDSourceDisplay" OnItemCommand="RepeaterAnnouncements_ItemCommand">
        <ItemTemplate>
            <div class="announcement-item">
                <div class="date">
                    <span class="day"><%# DataBinder.Eval(Container.DataItem, "DateTime", "{0:yyyy-MM-dd}") %></span>
                    <span class="time"><%# DataBinder.Eval(Container.DataItem, "DateTime", "{0:HH:mm}") %></span>
                </div>
                <div class="separator"></div>
                <div class="content">
                    <div class="text-and-buttons">
                        <div class="text">
                            <h3><%# Eval("Title") %></h3>
                            <p>
                                <%# Eval("Content") %>
                            </p>
                            <!-- Display LastUpdated info if it's not NULL -->
                            <%--<asp:Label ID="lblLastUpdated" runat="server" CssClass="last-updated" 
                                      Text='<%# Eval("LastUpdated") != DBNull.Value ? "Last Updated: " + DataBinder.Eval(Container.DataItem, "LastUpdated", "{0:yyyy-MM-dd HH:mm}") : "" %>' />--%>
                            <asp:Label ID="lblModifiedStatus" runat="server" CssClass="modified-status"
               Text='<%# Eval("LastUpdated") != DBNull.Value ? "This announcement was modified at " + DataBinder.Eval(Container.DataItem, "LastUpdated", "{0:yyyy-MM-dd HH:mm}") : "" %>' />
                        </div>
                        <div class="buttons">
                            <asp:Button
                                runat="server"
                                Text="Edit"
                                CssClass="edit-button"
                                CommandName="Edit"
                                CommandArgument='<%# Eval("AnnouncementId") %>' />
                            <asp:Button
                                runat="server"
                                Text="Delete"
                                CssClass="delete-button"
                                CommandName="Delete"
                                CommandArgument='<%# Eval("AnnouncementId") %>'
                                OnClientClick="return confirmDelete();" />
                        </div>
                    </div>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>
        <div class="modal-edit" id="editModal" style="display: none;">
        <div class="modal">
            <div class="modal-header">
                <span class="modal-title">Edit Announcement</span>
                <span class="close" onclick="closeModal()">&times;</span>
            </div>
            <div class="modal-body">
                <label for="EditTitle">Title</label>
                <asp:TextBox ID="EditTitle" runat="server" CssClass="form-control" Placeholder="Title"></asp:TextBox>
                <label for="EditContent">Content</label>
                <asp:TextBox ID="EditContent" runat="server" CssClass="form-control" TextMode="MultiLine" Placeholder="Content"></asp:TextBox>
            </div>
            <div class="modal-footer">
                <asp:Button ID="SaveEditButton" runat="server" CssClass="btn btn-primary" Text="Save" OnClick="SaveEditButton_Click" />
                <button type="button" class="btn btn-secondary" onclick="closeModal()">Close</button>
            </div>
        </div>
    </div>


    </div>
    <script>
        //push announcement form
        function openNewModal() {
            document.getElementById("newAnnouncementModal").style.display = "flex";
        }

        function closeNewModal() {
            document.getElementById("newAnnouncementModal").style.display = "none";
        }

        // Attach the function to the Push Announcement button
        document.getElementById('<%= btnPushAnnouncement.ClientID %>').onclick = function (e) {
            e.preventDefault(); // Prevents postback
            openNewModal();
        };


        function openModal() {
            document.querySelector(".modal-edit").style.display = "flex";
        }

        function closeModal() {
            document.querySelector(".modal-edit").style.display = "none";
        }
        //confirm delete dialog
        function confirmDelete() {
            return confirm("Are you sure you want to delete this announcement?");
        }
    </script>
</asp:Content>
