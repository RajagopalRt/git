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
    public class EventDetailsDAL
    {
        public bool SaveEventDetails(SaveEventDetailsDTO obj)
        {
            bool res = false;
            obj.CreatedBy = "1001";
            SqlCommand cmd = new SqlCommand("sp_SaveEventDetail");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_StudentId", obj.StudentId);
            cmd.Parameters.AddWithValue("@p_Name", obj.Name);
            cmd.Parameters.AddWithValue("@p_Address", obj.Address);
            cmd.Parameters.AddWithValue("@p_Department", obj.Department);
            cmd.Parameters.AddWithValue("@p_Section", obj.Section);
            cmd.Parameters.AddWithValue("@p_Class", obj.Class);
            cmd.Parameters.AddWithValue("@p_Date", obj.Date);
            cmd.Parameters.AddWithValue("@p_CollegeName", obj.CollegeName);
            cmd.Parameters.AddWithValue("@p_FromTime", obj.FromTime);
            cmd.Parameters.AddWithValue("@p_ToTime", obj.ToTime);
            cmd.Parameters.AddWithValue("@p_EventType", obj.EventType);
            cmd.Parameters.AddWithValue("@p_Status", obj.Status);
            cmd.Parameters.AddWithValue("@p_Purpose", obj.Purpose);
            //cmd.Parameters.AddWithValue("@p_ApprovedStaffBy", obj.ApprovedStaffBy);
            //cmd.Parameters.AddWithValue("@p_ApprovedHodBy", obj.ApprovedHodBy);
            //cmd.Parameters.AddWithValue("@p_StaffApprovalDate", obj.StaffApprovalDate);
            //cmd.Parameters.AddWithValue("@p_HodApprovalDate", obj.HodApprovalDate);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.CreatedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        //public bool ModifyDepartment(ModifyDepartmentDTO obj)
        //{
        //    bool res = false;
        // obj.ModifiedBy = "1002";
        //    SqlCommand cmd = new SqlCommand("sp_ModifyDepartment");
        //    cmd.CommandType = CommandType.StoredProcedure;
        //    cmd.Parameters.AddWithValue("@p_DepartmentId", obj.DepartmentId);
        //    cmd.Parameters.AddWithValue("@p_Name", obj.Name);
        //    cmd.Parameters.AddWithValue("@p_Code", obj.Code);
        //    cmd.Parameters.AddWithValue("@p_CollegeId", obj.CollegeId);
        //    cmd.Parameters.AddWithValue("@p_ActionBy", obj.ModifiedBy);
        //    int result = new DBlayer().ExecuteNonQuery(cmd);
        //    if (result != Int32.MaxValue)
        //    {
        //        res = true;
        //    }
        //    return res;
        //}

        public bool RemoveEventDetail(RemoveEventDetailsDTO obj)
        {
            bool res = false;
            SqlCommand cmd = new SqlCommand("sp_RemoveEventDetail");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_EventId", obj.EventId);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        public List<EventDetailsDTO> SelectEvent()
        {
            List<EventDetailsDTO> even = new List<EventDetailsDTO>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectEvent");
                cmd.CommandType = CommandType.StoredProcedure;
                even = dblayer.GetEntityList<EventDetailsDTO>(cmd);
            }
            return even;
        }
    }
}