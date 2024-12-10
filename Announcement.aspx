<%@ Page Title="" Language="C#" MasterPageFile="~/Master/Client.Master" AutoEventWireup="true" CodeBehind="Announcement.aspx.cs" Inherits="fyp.Announcement" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
    <link rel="stylesheet" href="assets/css/main.css" />
    <link rel="stylesheet" href="assets/css/announcement.css" />

        <link rel="stylesheet" href="assets/css/modal.css" />
    <style>
        #modalContent {
    white-space: pre-wrap; /* Preserves both spaces and line breaks */
    font-family: Arial, sans-serif; /* Optional: make text clear */
}
    </style>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
     <!--Body Content-->

    <header>
                        
        <h2>Your Inbox</h2>
                    </header>
    
                <div class="inbox-container">

                    <asp:Repeater ID="rptMessage" runat="server" >
                        <ItemTemplate>
                            <div id="<%# Eval("ItemType") %><%# Eval("ItemId") %>" 
                                class="message <%# Convert.ToBoolean(Eval("IsUnread")) ? "unread" : "" %>" 
                               onclick='<%# string.Format("openModal(\"{0}\", \"{1}\", \"{2}\", \"{3}\", \"{4}\")", 
        HttpUtility.JavaScriptStringEncode(Eval("Title").ToString()), 
        HttpUtility.JavaScriptStringEncode(Eval("Content").ToString()), 
        Eval("DateTime"), 
        Eval("ItemType"), 
        Eval("ItemId")) %>'>
                        <div class="message-title"> 
                            <span class="title-text"><%# Eval("ItemType") %>: <%# Eval("Title") %></span>
                            <span class="message-datetime"><%# Eval("DateTime") %></span>

                        </div>
                        <div class="message-content"><%# Eval("Content") %></div>
                    </div>
                        </ItemTemplate>
                        </asp:Repeater>
                </div>

<div class="modal fade" id="exampleModalCenter" tabindex="-1" role="dialog" aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="modalTitle">Title Placeholder</h5>
            </div>
            <div class="modal-body" id="modalContent">
                Content Placeholder
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-category btn-category-save" id="closeModal">Close</button>
            </div>
        </div>
    </div>
</div>


</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
        <!-- Scripts -->
    <script src="assets/js/jquery.dropotron.min.js"></script>
    <script src="assets/js/jquery.scrolly.min.js"></script>
    <script src="assets/js/jquery.scrollex.min.js"></script>
    <script src="assets/js/browser.min.js"></script>
    <script src="assets/js/breakpoints.min.js"></script>
    <script src="assets/js/util.js"></script>
        <script src="assets/js/main.js"></script>
        <script src="assets/js/bootstrap.min.js"></script>
    <script>
        // Function to open the modal
        function openModal(title, content, time, type, id) {
            // Update modal title and content
            document.getElementById('modalTitle').textContent = type + " : " + title + " - " + time;
            document.getElementById('modalContent').textContent = content;

            // Show modal
            const modal = document.getElementById('exampleModalCenter');
            modal.classList.add('show');
            modal.style.display = 'block';
            document.body.classList.add('modal-open');

            $.ajax({
                url: 'Announcement.aspx/changeStatus',
                type: 'POST',
                data: JSON.stringify({ table: type, itemId: id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "SUCCESS") {
                        document.getElementById(type + id).classList.remove('unread');
                    }
                }
            });
        }

        // Function to close the modal
        function closeModal() {
            const modal = document.getElementById('exampleModalCenter');
            modal.classList.remove('show');
            modal.style.display = 'none';
            document.body.classList.remove('modal-open');

        }

        // Attach close event to the button
        document.getElementById('closeModal').addEventListener('click', closeModal);
    </script>
</asp:Content>
