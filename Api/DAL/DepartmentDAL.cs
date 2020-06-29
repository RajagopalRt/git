using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using EmsApi.DBL;
using EmsApi.Models.EMS;

namespace EmsApi.DAL
{
    public class DepartmentDAL
    {
        public bool SaveDepartment(SaveDepartmentDTO obj)
        {
            bool res = false;
            obj.CreatedBy = "1001";
            SqlCommand cmd = new SqlCommand("sp_SaveDepartment");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_Name", obj.Name);
            cmd.Parameters.AddWithValue("@p_Code", obj.Code);
            cmd.Parameters.AddWithValue("@p_CollegeId", obj.CollegeId);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.CreatedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public bool ModifyDepartment(ModifyDepartmentDTO obj)
        {
            bool res = false;
            obj.ModifiedBy = "1002";
            SqlCommand cmd = new SqlCommand("sp_ModifyDepartment");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_DepartmentId", obj.DepartmentId);
            cmd.Parameters.AddWithValue("@p_Name", obj.Name);
            cmd.Parameters.AddWithValue("@p_Code", obj.Code);
            cmd.Parameters.AddWithValue("@p_CollegeId", obj.CollegeId);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.ModifiedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        public bool RemoveDepartment(RemoveDepartmentDTO obj)
        {
            bool res = false;
            SqlCommand cmd = new SqlCommand("sp_RemoveDepartment");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_DepartmentId", obj.DepartmentId);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        public List<DepartmentDTO> SelectDepartment()
        {
            List<DepartmentDTO> dept = new List<DepartmentDTO>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectDepartment");
                cmd.CommandType = CommandType.StoredProcedure;
                dept = dblayer.GetEntityList<DepartmentDTO>(cmd);
            }
            return dept;
        }
        public List<College1DTO> SelectCollegeName()
        {
            List<College1DTO> clg1 = new List<College1DTO>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectCollegeName");
                cmd.CommandType = CommandType.StoredProcedure;
                clg1 = dblayer.GetEntityList<College1DTO>(cmd);
            }
            return clg1;
        }
    }
}