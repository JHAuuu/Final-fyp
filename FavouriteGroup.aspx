    <%@ Page Title="" Language="C#" MasterPageFile="~/Master/Client.Master" AutoEventWireup="true" CodeBehind="FavouriteGroup.aspx.cs" Inherits="fyp.FavouriteGroup" %>
<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">
    Your Favourites
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
        <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, user-scalable=no" />
    <link rel="stylesheet" href="assets/css/main.css" />
    <link rel="stylesheet" href="assets/css/modal.css" />
    <link rel="stylesheet" href="assets/css/sweetalert2-theme-bootstrap-4/bootstrap-4.min.css">
    <link rel="stylesheet" href="assets/css/favouriteGroup.css" />
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

                <div class="container">
                <div class="row" style="align-items: center;display: flex; justify-content: space-between;">
                <header>
                    <h2><a href="#">Your Favourites</a></h2>
                </header>

                <button class="add-group" data-toggle="modal" data-target="#exampleModalCenter"><i
                    class="fas fa-plus"></i> Add Group</button>
                </div>
                <!--Body Content-->
                <table>
                    <thead>
                        <tr>
                            <th>Title</th>
                            <th>Date Created</th>
                            <th>Last Added</th>
                            <th>Action</th> <!-- New column for the delete action -->
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater runat="server" ID="rptGroup">
                            <ItemTemplate>
                                <tr id="<%# Eval("GroupId") %>">
                            <td>
                                <a href="Favourite.aspx?groupId=<%# Eval("GroupId") %>"><div class="book-title"><%# Eval("GroupName") %></div></a>
                                <div class="book-details"> <%# Eval("TotalBooks") %> Books</div>
                            </td>
                            <td><%# Eval("GroupDate") %></td>
                            <td><%# Eval("LastAddedDate") %></td>
                                   
                            <td>
                                 <%# string.IsNullOrEmpty(Eval("GroupId").ToString()) ? "" : "<i class='fas fa-trash action-icon' onclick='deleteGroup(\"" + Eval("GroupId") + "\")'></i>" %>

                            </td> <!-- Trash icon -->
                                   
                        </tr>
                            </ItemTemplate>
                        </asp:Repeater>

                    </tbody>
                </table>

            </div>

        <div class="modal fade" id="exampleModalCenter" tabindex="-1" role="dialog"
        aria-labelledby="exampleModalCenterTitle" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLongTitle">Choose your type</h5>

                </div>
                <div class="modal-body">
                    <label for="groupName">Group Name</label><br/>
                    <input type="text" class="form-control" id="groupName" placeholder="Enter group name">

                </div>
                <div class="modal-footer">
                    <button type="button" class="btn-category btn-close" data-dismiss="modal" onclick="clearInput()">No thanks</button>
                    <button type="button" class="btn-category btn-category-save" onclick="CreateGroup()">Create</button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
     <script src="assets/js/jquery.min.js"></script>
    <script src="assets/js/jquery.dropotron.min.js"></script>
    <script src="assets/js/jquery.scrolly.min.js"></script>
    <script src="assets/js/jquery.scrollex.min.js"></script>
    <script src="assets/js/browser.min.js"></script>
    <script src="assets/js/breakpoints.min.js"></script>
    <script src="assets/js/util.js"></script>
    <script src="assets/js/SSmain.js"></script>
    <script src="assets/js/pagination.js"></script>
    <script src="assets/js/bootstrap.min.js"></script>
     <script src="assets/js/sweetalert2/sweetalert2.min.js"></script>
    <script>

        function CreateGroup() {
            console.log("clicked")
            var groupName = document.getElementById('groupName').value;
            $.ajax({
                type: "POST",
                url: "FavouriteGroup.aspx/CreateGroup",
                data: '{name: "' + groupName +
                    ' "}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d == "SUCCESS") {
                        Swal.fire(
                            'Change Successfully!',
                            '',
                            'success'
                        ).then(function () {
                            window.location.href = "FavouriteGroup.aspx";
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Something Wrong',
                            text: response.d
                        })
                    }
                },
                failure: function (response) {
                    Toast.fire({
                        icon: 'error',
                        title: 'Record Save Failed'
                    });
                }
            });

        }

        function CreateGroup() {
            console.log("clicked")
            var groupName = document.getElementById('groupName').value;
            $.ajax({
                type: "POST",
                url: "FavouriteGroup.aspx/CreateGroup",
                data: '{name: "' + groupName +
                    ' "}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d == "SUCCESS") {
                        Swal.fire(
                            'Change Successfully!',
                            '',
                            'success'
                        ).then(function () {
                            window.location.href = "FavouriteGroup.aspx";
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Something Wrong',
                            text: response.d
                        })
                    }
                },
                failure: function (response) {
                    Toast.fire({
                        icon: 'error',
                        title: 'Record Save Failed'
                    });
                }
            });

        }

        function clearInput() {
            
            document.getElementById("groupName").value = "";
        }

        function deleteGroup(groupId) {
            Swal.fire({
                title: 'Delete Group',
                html: `<p>Do you want to delete <strong>only the group</strong> or <strong>all items within the group</strong> as well?</p>`,
                icon: 'warning',
                showCancelButton: true,
                showDenyButton: true,
                confirmButtonText: 'Delete All Items',
                denyButtonText: 'Delete Group Only',
                cancelButtonText: 'Cancel',
                confirmButtonColor: '#e74c3c',  // Color for delete all items
                denyButtonColor: '#3498db',     // Color for delete group only
                cancelButtonColor: '#95a5a6',
                buttonsStyling: true
            }).then((result) => {
                if (result.isConfirmed) {
                    // User chose to delete all items within the group
                    $.ajax({
                        url: 'FavouriteGroup.aspx/DeleteAll',
                        type: 'POST',
                        data: '{groupId: "' + groupId +
                            ' "}',
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            if (response.d == "SUCCESS") {
                                document.getElementById(groupId).remove(); // Remove row
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Deleted!',
                                    text: 'The group and all items within it have been deleted.',
                                    confirmButtonText: 'OK',
                                    confirmButtonColor: '#3498db'
                                });
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error',
                                    text: response.d,
                                    confirmButtonText: 'Try again',
                                    confirmButtonColor: '#e67e22'
                                });
                            }
                        }
                    });
                } else if (result.isDenied) {
                    // User chose to delete only the group
                    $.ajax({
                        url: 'FavouriteGroup.aspx/DeleteGroupOnly',
                        type: 'POST',
                        data: '{groupId: "' + groupId +
                            ' "}',
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            if (response.d == "SUCCESS") {
                                document.getElementById(groupId).remove(); // Remove row
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Group Deleted',
                                    text: 'Only the group has been deleted.',
                                    confirmButtonText: 'OK',
                                    confirmButtonColor: '#3498db'
                                });
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error',
                                    text: response.d,
                                    confirmButtonText: 'Try again',
                                    confirmButtonColor: '#e67e22'
                                });
                            }
                        }
                    });
                }
            });
        }

    </script>
</asp:Content>
