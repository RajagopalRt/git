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
    public class EmployeeDAL
    {
        public bool SaveEmployee(SaveEmployeeDTO obj)
        {
            bool res = false;
            obj.CreatedBy = "1001";
            SqlCommand cmd = new SqlCommand("sp_SaveEmployee");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_EmployeeName", obj.EmployeeName);
            cmd.Parameters.AddWithValue("@p_DateOfJoining", obj.DateOfJoining);
            cmd.Parameters.AddWithValue("@p_EmployeeType", obj.EmployeeType);
            cmd.Parameters.AddWithValue("@p_DepartmentId", obj.DepartmentId);
            cmd.Parameters.AddWithValue("@p_RoleId", obj.RoleId);
            cmd.Parameters.AddWithValue("@p_MobileNo", obj.MobileNo);
            cmd.Parameters.AddWithValue("@p_Email", obj.Email);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.CreatedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public bool ModifyEmployee(ModifyEmployeeDTO obj)
        {
            bool res = false;
            obj.ModifiedBy = "1002";
            SqlCommand cmd = new SqlCommand("sp_ModifyEmployee");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_EmployeeId", obj.EmployeeId);
            cmd.Parameters.AddWithValue("@p_EmployeeName", obj.EmployeeName);
            cmd.Parameters.AddWithValue("@p_DateOfJoining", obj.DateOfJoining);
            cmd.Parameters.AddWithValue("@p_EmployeeType", obj.EmployeeType);
            cmd.Parameters.AddWithValue("@p_DepartmentId", obj.DepartmentId);
            cmd.Parameters.AddWithValue("@p_RoleId", obj.RoleId);
            cmd.Parameters.AddWithValue("@p_MobileNo", obj.MobileNo);
            cmd.Parameters.AddWithValue("@p_Email", obj.Email);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.ModifiedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public bool RemoveEmployee(RemoveEmployeeDTO obj)
        {
            bool res = false;
            SqlCommand cmd = new SqlCommand("sp_RemoveEmployee");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_EmployeeId", obj.EmployeeId);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public List<EmployeeDTO> SelectEmployee()
        {
            List<EmployeeDTO> emp = new List<EmployeeDTO>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectEmployee");
                cmd.CommandType = CommandType.StoredProcedure;
                emp = dblayer.GetEntityList<EmployeeDTO>(cmd);
            }
            return emp;
        }
        public List<RoleName> RoleName()
        {
            List<RoleName> r = new List<RoleName>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_RoleName");
                cmd.CommandType = CommandType.StoredProcedure;
                r = dblayer.GetEntityList<RoleName>(cmd);
            }
            return r;
        }
    }
}