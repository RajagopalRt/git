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
    public class Hod_AllocationDAL
    {
        public bool SaveHod_Allocation(SaveHod_AllocationDTO obj)
        {
            bool res = false;
            obj.CreatedBy = "1001";
            SqlCommand cmd = new SqlCommand("sp_SaveHod_Allocation");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_DepartmentId", obj.DepartmentId);
            cmd.Parameters.AddWithValue("@p_EmployeeId", obj.EmployeeId);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.CreatedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public bool ModifyHod_Allocation(ModifyHod_AllocationDTO obj)
        {
            bool res = false;
            obj.ModifiedBy = "1002";
            SqlCommand cmd = new SqlCommand("sp_ModifyHod_Allocation");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_HodAllocationId", obj.HodAllocationId);
            cmd.Parameters.AddWithValue("@p_departmentId", obj.DepartmentId);
            cmd.Parameters.AddWithValue("@p_EmployeeId", obj.EmployeeId);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.ModifiedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public bool RemoveHod_Allocation(RemoveHod_AllocationDTO obj)
        {
            bool res = false;
            SqlCommand cmd = new SqlCommand("sp_RemoveHod_AllocationId");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_HodAllocationId", obj.HodAllocationId);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public List<Hod_AllocationDTO> SelectHod_Allocation()
        {
            List<Hod_AllocationDTO> hoda = new List<Hod_AllocationDTO>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectHod_Allocation");
                cmd.CommandType = CommandType.StoredProcedure;
                hoda = dblayer.GetEntityList<Hod_AllocationDTO>(cmd);
            }
            return hoda;
        }
        public List<Employee> Employee()
        {
            List<Employee> Employee = new List<Employee>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_Employee");
                cmd.CommandType = CommandType.StoredProcedure;
                Employee = dblayer.GetEntityList<Employee>(cmd);
            }
            return Employee;
        }
    }
}