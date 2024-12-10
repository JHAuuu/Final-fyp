using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace fyp
{
    public partial class Favourite : UserPage
    {
        static int userid = 0;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["PatronId"] != null)
                {
                    userid = Convert.ToInt32(Session["PatronId"].ToString());

                    string groupId = Request.QueryString["groupId"];

                    if (!string.IsNullOrEmpty(groupId))
                    {
                        DataTable dt = GetFromGroup(groupId);
                        if (dt.Rows.Count > 0)
                        {
                            rptBooks.DataSource = dt;
                            rptBooks.DataBind();
                        }

                    }
                    else
                    {
                        DataTable dt = GetAllFav();
                        if (dt.Rows.Count > 0)
                        {
                            rptBooks.DataSource = dt;
                            rptBooks.DataBind();
                        }
                    }

                    if (getAllFavGroup().Rows.Count > 0)
                    {
                        rptGroup.DataSource = getAllFavGroup();
                        rptGroup.DataBind();
                    }
                }
            }
        }

        public DataTable getAllFavGroup()
        {
            try
            {
                string query = @"SELECT FavGrpId, FavGrpName FROM FavGroup WHERE PatronId = @userid";
                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]
                {
                    "userid",userid.ToString()
                });

                return originalDt;
            }
            catch (Exception ex)
            {
                return new DataTable();
            }
        }
        public DataTable GetAllFav()
        {
            try
            {
                string query = @"SELECT f.FavId, f.BookId, f.Date as AddedDate, b.BookTitle, b.BookDesc, b.BookImage FROM Favourite as f INNER JOIN Book AS b ON f.BookId = b.BookId WHERE PatronId = @userid";
                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]
                {
                    "userid",userid.ToString()
                });
                DataTable dt = new DataTable();
                dt.Columns.Add("FavId", typeof(string));
                dt.Columns.Add("BookId", typeof(string));
                dt.Columns.Add("AddedDate", typeof(string));
                dt.Columns.Add("BookTitle", typeof(string));
                dt.Columns.Add("BookDesc", typeof(string));
                dt.Columns.Add("BookImage", typeof(string));

                foreach (DataRow originalRow in originalDt.Rows)
                {
                    DataRow newRow = dt.NewRow();
                    foreach (DataColumn column in originalDt.Columns)
                    {
                        if (column.ColumnName == "BookImage" && originalRow[column] != DBNull.Value)
                        {

                            newRow[column.ColumnName] = ImageHandler.GetImage((byte[])originalRow[column]);
                        }
                        else if (column.ColumnName != "BookImage" && originalRow[column] != DBNull.Value)
                        {
                            newRow[column.ColumnName] = originalRow[column].ToString();
                        }
                        else
                        {
                            newRow[column.ColumnName] = DBNull.Value;
                        }

                    }
                    dt.Rows.Add(newRow);
                }

                return dt;
            } catch (Exception ex)
            {
                return new DataTable();
            }

        }

        public DataTable GetFromGroup(string groupId)
        {
            try
            {
                string checkQuery = @"SELECT COUNT(FavGrpId) FROM FavGroup WHERE FavGrpId = @groupId";
                int checkGroup = Convert.ToInt32(DBHelper.ExecuteScalar(checkQuery, new string[]
                {
                      "groupId",groupId
                }));

                if(checkGroup == 0)
                {
                    Response.Redirect("error/404PageNotFound.aspx");
                }

                string query = @"SELECT f.FavId, f.BookId, f.Date as AddedDate, b.BookTitle, b.BookDesc, b.BookImage FROM Favourite as f  INNER JOIN FavouriteGrouping as fg ON f.FavId = fg.FavId INNER JOIN Book AS b ON f.BookId = b.BookId WHERE f.PatronId = @userid AND fg.FavGrpId = @groupId ORDER BY AddedDate DESC";
                DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]
                {
                    "userid",userid.ToString(),
                    "groupId",groupId
                });
                DataTable dt = new DataTable();
                dt.Columns.Add("FavId", typeof(string));
                dt.Columns.Add("BookId", typeof(string));
                dt.Columns.Add("AddedDate", typeof(string));
                dt.Columns.Add("BookTitle", typeof(string));
                dt.Columns.Add("BookDesc", typeof(string));
                dt.Columns.Add("BookImage", typeof(string));

                foreach (DataRow originalRow in originalDt.Rows)
                {
                    DataRow newRow = dt.NewRow();
                    foreach (DataColumn column in originalDt.Columns)
                    {
                        if (column.ColumnName == "BookImage" && originalRow[column] != DBNull.Value)
                        {

                            newRow[column.ColumnName] = ImageHandler.GetImage((byte[])originalRow[column]);
                        }
                        else if (column.ColumnName != "BookImage" && originalRow[column] != DBNull.Value)
                        {
                            newRow[column.ColumnName] = originalRow[column].ToString();
                        }
                        else
                        {
                            newRow[column.ColumnName] = DBNull.Value;
                        }

                    }
                    dt.Rows.Add(newRow);
                }


                return dt;
            }
            catch (Exception ex)
            {
                return new DataTable();
            }

        }

        [System.Web.Services.WebMethod(Description = "Remove Favourite from group")]
        public static string RemoveFromGroup(string groupId, string bookId)
        {
            try
            {

                string getfavId = @"SELECT FavId FROM Favourite WHERE BookId = @bookId AND PatronId = @userid";
                int favId = Convert.ToInt32(DBHelper.ExecuteScalar(getfavId, new string[]
                {
                    "bookId", bookId,
                    "userid",userid.ToString()
                }));


                if (!string.IsNullOrEmpty(groupId))
                {
                    string query = @"DELETE FROM FavouriteGrouping WHERE FavId = @favId AND FavGrpId = @groupId";
                    int removeGrouping = DBHelper.ExecuteNonQuery(query, new string[]
                    {
                    "favId", favId.ToString(),
                    "groupId", groupId
                    });

                    if (removeGrouping > 0)
                    {
                        return "SUCCESS";
                    }
                    else
                    {
                        return "Cannot Remove";
                    }
                }
                else
                {
                    string queryGrouping = @"DELETE FROM FavouriteGrouping WHERE FavId = @favId";
                    int removeGrouping = DBHelper.ExecuteNonQuery(queryGrouping, new string[]
                    {
                    "favId", favId.ToString()
                    });

                    if (removeGrouping > 0)
                    {
                        string queryFav = @"DELETE FROM Favourite WHERE FavId = @favId";
                        int removeFav = DBHelper.ExecuteNonQuery(queryFav, new string[]
                        {
                    "favId", favId.ToString()
                        });

                        if (removeFav > 0)
                        {
                            return "SUCCESS";
                        }
                        else
                        {
                            return "Cannot Remove Favourite";
                        }
                    }
                    else
                    {
                        return "Cannot Remove Grouping";
                    }
                }


            } catch (Exception ex)
            {
                return $"Error: {ex.Message}";
            }
        }

        [System.Web.Services.WebMethod(Description = "Remove From Favourite")]
        public static string RemoveFromAll(string bookId)
        {
            try
            {
                string getfavId = @"SELECT FavId FROM Favourite WHERE BookId = @bookId AND PatronId = @userid";
                int favId = Convert.ToInt32(DBHelper.ExecuteScalar(getfavId, new string[]
                {
                    "bookId", bookId,
                    "userid",userid.ToString()
                }));



                string queryGrouping = @"DELETE FROM FavouriteGrouping WHERE FavId = @favId";
                int removeGrouping = DBHelper.ExecuteNonQuery(queryGrouping, new string[]
                {
                    "favId", favId.ToString()
                });


                string queryFav = @"DELETE FROM Favourite WHERE FavId = @favId";
                int removeFav = DBHelper.ExecuteNonQuery(queryFav, new string[]
                {
                    "favId", favId.ToString()
                });

                if (removeFav > 0)
                {
                    return "SUCCESS";
                }
                else
                {
                    return "Cannot Remove Favourite";
                }



            }
            catch (Exception ex)
            {
                return ex.ToString();
            }
        }

        [System.Web.Services.WebMethod(Description = "Add to Favourite only")]
        public static string AddToDefaultGroup(string bookId)
        {
            try
            {
                // Replace with your database logic to add the favorite item to the default group
                // Example (pseudo-code):
                // Database.AddToGroup(favId, "defaultGroupId");

                string query = @"INSERT INTO Favourite (BookId, PatronId, Date) VALUES (@bookId, @userId, CAST(GETDATE() AS DATE));";
                int insertFav = DBHelper.ExecuteNonQuery(query, new string[]
                {
                    "bookId", bookId,
                    "userId", userid.ToString()
                });

                if (insertFav > 0)
                {
                    return "SUCCESS";
                }
                else
                {
                    return "Error Adding as favourite";
                }

            }
            catch (Exception ex)
            {
                // Log the exception and return an error message
                return "ERROR: " + ex.ToString();
            }
        }

        [System.Web.Services.WebMethod(Description = "Add to Groups")]
        public static string AddToGroups(string bookId, List<string> groupIds)
        {
            try
            {
                string query = @"INSERT INTO Favourite (BookId, PatronId, Date) VALUES (@bookId, @userId, CAST(GETDATE() AS DATE));  SELECT SCOPE_IDENTITY();";
                object insertFav = DBHelper.ExecuteScalar(query, new string[]
                {
                    "bookId", bookId,
                    "userId", userid.ToString()
                });
                int FavId = Convert.ToInt32(insertFav);
                int insertGrouping = 0;
                if (FavId != 0)
                {
                    foreach (string groupId in groupIds)
                    {
                        string groupingQuery = @"INSERT INTO FavouriteGrouping (FavId, FavGrpId) VALUES (@favId, @groupId);";
                        insertGrouping = DBHelper.ExecuteNonQuery(groupingQuery, new string[]
                        {
                            "favId", FavId.ToString(),
                            "groupId", groupId
                        });
                    }
                    if (insertGrouping > 0)
                    {
                        return "SUCCESS";
                    }
                    else
                    {
                        return "Error Adding as Grouping";
                    }

                }
                else
                {
                    return "Error Adding as favourite";
                }
                // Assuming you have a database connection and logic to insert the book into groups

               
            }
            catch (Exception ex)
            {
                // Log the error and return a failure message
                return "ERROR: " + ex.Message;
            }
        }
    }
}