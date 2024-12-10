using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace fyp
{
    public partial class FavouriteGroup : System.Web.UI.Page
    {
        static int userid = 0;
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["PatronId"] != null)
                {
                    userid = Convert.ToInt32(Session["PatronId"].ToString());

                    DataTable groupDt = getUserFavGroup();

                    if(groupDt.Rows.Count > 0)
                    {
                        rptGroup.DataSource = groupDt;
                        rptGroup.DataBind();
                    }
                }
                else
                {
                    Response.Redirect("Home.aspx");
                }
            }
        }

        public DataTable getUserFavGroup()
        {
            try
            {
                if(userid != 0)
                {
                    string query = @"SELECT fg.FavGrpId as GroupId, fg.FavGrpName as GroupName, fg.Date AS GroupDate, count(f.FavId) as TotalBooks, MAX(f.Date) AS LastAddedDate FROM FavGroup AS fg LEFT JOIN FavouriteGrouping AS fgLink ON fg.FavGrpId = fgLink.FavGrpId LEFT JOIN Favourite AS f ON fgLink.FavId = f.FavId WHERE fg.PatronId = @userid GROUP BY fg.FavGrpId, fg.FavGrpName, fg.PatronId, fg.Date ORDER BY fg.FavGrpId;
                        ";

                    DataTable originalDt = DBHelper.ExecuteQuery(query, new string[]
                    {
                        "userid",userid.ToString()
                    });

                    DataTable dt = new DataTable();
                    dt.Columns.Add("GroupId", typeof(string));
                    dt.Columns.Add("GroupName", typeof(string));
                    dt.Columns.Add("GroupDate", typeof(string));
                    dt.Columns.Add("TotalBooks", typeof(string));
                    dt.Columns.Add("LastAddedDate", typeof(string));

                    DataRow defaultRow = getDefaultFavGroup(dt);
                    if(defaultRow != null)
                    {
                        dt.Rows.Add(defaultRow);

                        foreach (DataRow originalRow in originalDt.Rows)
                        {
                            DataRow newRow = dt.NewRow();
                            foreach (DataColumn column in originalDt.Columns)
                            {
                                if(column.ColumnName == "GroupDate" || column.ColumnName == "LastAddedDate")
                                {
                                    if (originalRow[column] != DBNull.Value)
                                    {
                                        // Format the date as "Jun 17, 2022"
                                        newRow[column.ColumnName] = Convert.ToDateTime(originalRow[column]).ToString("MMM dd, yyyy");
                                    }
                                    else
                                    {
                                        // If the date is DBNull, set it to "-"
                                        newRow[column.ColumnName] = "-";
                                    }
                                }
                                else
                                {
                                    newRow[column.ColumnName] = originalRow[column].ToString();
                                }
                                    


                            }
                            dt.Rows.Add(newRow);
                        }

                        return dt;
                    }
                    else
                    {
                        return new DataTable();
                    }
                   
                }
            }catch(Exception ex)
            {
                return new DataTable();
            }

            return new DataTable();
        }


        public DataRow getDefaultFavGroup(DataTable dt)
        {
            try
            {
                string query = @"SELECT COUNT(FavId) AS FavCount, MAX(Date) AS LastAddedDate FROM Favourite WHERE PatronId = @userid";
                DataTable originalDt = DBHelper.ExecuteQuery(query, new String[]
                {
                "userid",userid.ToString()
                });

                DataRow originalRow = originalDt.Rows[0];

                DataRow newRow = dt.NewRow();
                if (originalDt.Rows.Count > 0)
                {
                    newRow["GroupId"] = DBNull.Value;
                    newRow["GroupName"] = "All favourites books";
                    newRow["GroupDate"] = "-";
                    newRow["TotalBooks"] = originalRow["FavCount"];
                    newRow["LastAddedDate"] = Convert.ToDateTime(originalRow["LastAddedDate"]).ToString("MMM dd, yyyy");
                    
                }
                else
                {
                    newRow["GroupId"] = DBNull.Value;
                    newRow["GroupName"] = "All favourites books";
                    newRow["GroupDate"] = "-";
                    newRow["TotalBooks"] = "0";
                    newRow["LastAddedDate"] = "-";
                }


                return newRow;
            }
            catch(Exception ex)
            {
                return null;
            }
            
        }

        [System.Web.Services.WebMethod(Description = "Create Group")]
        public static string CreateGroup(string name)
        {
            try
            {
                string selectQuery = @"SELECT FavGrpName FROM FavGroup WHERE PatronId = @userid;";
                string insertQuery = @"INSERT FavGroup (FavGrpName, PatronId, Date) Values (@name, @userid, GETDATE())";

                DataTable selectedDt = DBHelper.ExecuteQuery(selectQuery, new string[]
                {
                    "userid",userid.ToString()
                });

              
                    foreach (DataRow selectedRow in selectedDt.Rows)
                    {
                        if (selectedRow["FavGrpName"].ToString() == name)
                        {
                            return "Choose Another Name";
                        }
                        
                    }

                int insertedQuery = DBHelper.ExecuteNonQuery(insertQuery, new string[]
                          {
                            "name",name,
                            "userid",userid.ToString()
                          });

                if (insertedQuery > 0)
                {
                    return "SUCCESS";
                }
                else
                {
                    return "Failed to create";
                }


            }
            catch(Exception ex)
            {
                return ex.ToString();
            }

        }


        [System.Web.Services.WebMethod(Description = "Delete Group with all item")]
        public static string DeleteAll(string groupId)
        {
            try
            {
                string delGroupingQuery = @"DELETE FavouriteGrouping WHERE FavGrpId = @groupId AND FavId = @favId";

                

                
                string delFavQuery = @"DELETE Favourite WHERE FavId = @favId";
                string getFavQuery = @"SELECT FavId FROM FavouriteGrouping WHERE FavGrpId = @groupId;";
                DataTable allFavDt = DBHelper.ExecuteQuery(getFavQuery, new String[]
                {
                    "groupId", groupId
                });

                if (allFavDt.Rows.Count > 0)
                {
                    

                    foreach (DataRow FavRow in allFavDt.Rows)
                    {
                        int delGrouping = DBHelper.ExecuteNonQuery(delGroupingQuery, new String[]
                        {
                            "groupId",groupId,
                            "favId",FavRow["FavId"].ToString()
                        });

                        if (delGrouping < 1)
                        {
                            return "Delete Grouping Problem";
                        }

                        int deleteFav = DBHelper.ExecuteNonQuery(delFavQuery, new String[]
                        {
                            "favId", FavRow["FavId"].ToString()
                        });

                        if(deleteFav < 1)
                        {
                            return "Delete Favourites Problem";
                        }
                    }
                }


                string delGroupQuery = @"DELETE FavGroup WHERE FavGrpId = @groupId";
                int delGroup = DBHelper.ExecuteNonQuery(delGroupQuery, new String[]
                {
                    "groupId",groupId
                });
                if (delGroup < 1)
                {
                    return "Delete Group Problem";
                }


                return "SUCCESS";
            }
            catch (Exception ex)
            {
                return ex.ToString();
            }
        }

        [System.Web.Services.WebMethod(Description = "Delete Group only")]
        public static string DeleteGroupOnly(string groupId)
        {
            try
            {
                string delGroupingQuery = @"DELETE FavouriteGrouping WHERE FavGrpId = @groupId";

                int delGrouping = DBHelper.ExecuteNonQuery(delGroupingQuery, new String[]
                {
                    "groupId",groupId
                });
                if (delGrouping < 1)
                {
                    return "Delete Grouping Problem";
                }

                string delGroupQuery = @"DELETE FavGroup WHERE FavGrpId = @groupId";
                int delGroup = DBHelper.ExecuteNonQuery(delGroupQuery, new String[]
                {
                    "groupId",groupId
                });
                if (delGroup < 1)
                {
                    return "Delete Group Problem";
                }


                return "SUCCESS";
            }
            catch (Exception ex)
            {
                return ex.ToString();
            }
        }
    }
}