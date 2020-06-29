using EmsApi.DBL;
using EmsApi.Models.EMS;
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace EmsApi.DAL
{
    public class HODApprovalDAL
    {
        public bool SaveHODApprovalDAL(SaveHODApprovalDTO obj)
        {
            bool res = false;
            SqlCommand cmd = new SqlCommand("sp_SaveHODApproval");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_EventId", obj.EventId);
            cmd.Parameters.AddWithValue("@p_StudentId", obj.StudentId);
            cmd.Parameters.AddWithValue("@p_Name", obj.Name);
            cmd.Parameters.AddWithValue("@p_CollegeName", obj.CollegeName);
            cmd.Parameters.AddWithValue("@p_Department", obj.Department);
            cmd.Parameters.AddWithValue("@p_Class", obj.Class);
            cmd.Parameters.AddWithValue("@p_Section", obj.Section);
            cmd.Parameters.AddWithValue("@p_EventType", obj.EventType);
            //cmd.Parameters.AddWithValue("@p_Purpose", obj.Purpose);
            cmd.Parameters.AddWithValue("@p_Date", obj.Date);
            cmd.Parameters.AddWithValue("@p_FromTime", obj.FromTime);
            cmd.Parameters.AddWithValue("@p_ToTime", obj.ToTime);
            cmd.Parameters.AddWithValue("@p_ApprovedStaff", obj.ApprovedStaff);
            cmd.Parameters.AddWithValue("@p_ApprovedHOD", obj.ApprovedHOD);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public bool RemoveHODApproval(RemoveHODApprovalDTO obj)
        {
            bool res = false;
            SqlCommand cmd = new SqlCommand("sp_RemoveHODApproval");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_EventId", obj.EventId);
            cmd.Parameters.AddWithValue("@p_StudentId", obj.StudentId);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public List<HODApprovalDTO> SelectHODApproval(SelectHODApprovalProcDTO obj)
        {
            List<HODApprovalDTO> hod = new List<HODApprovalDTO>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectHODApproval");
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@p_EventId", obj.EventId);
                cmd.Parameters.AddWithValue("@p_StudentId", obj.StudentId);
                hod = dblayer.GetEntityList<HODApprovalDTO>(cmd);
            }
            return hod;
        }
    }
}