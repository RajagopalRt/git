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
    public class StaffAllocationDAL
    {
        public bool SaveStaffAllocation(saveStaffAllocationDTO obj)
        {
            bool res = false;
            obj.CreatedBy = "1001";
            SqlCommand cmd = new SqlCommand("sp_SaveStaffAllocation");
            cmd.CommandType = CommandType.StoredProcedure;

            cmd.Parameters.AddWithValue("@p_ClassId", obj.ClassId);
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
        public bool ModifyStaffAllocation(ModifyStaffAllocationDTO obj)
        {
            bool res = false;
            obj.ModifiedBy = "1002";
            SqlCommand cmd = new SqlCommand("sp_ModifyStaffAllocation");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_StaffAllocationId", obj.StaffAllocationId);
            cmd.Parameters.AddWithValue("@p_ClassId", obj.ClassId);
            cmd.Parameters.AddWithValue("@p_DepartmentId", obj.DepartmentId);
            cmd.Parameters.AddWithValue("@p_EmployeeId", obj.EmployeeId);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.ModifiedBy);

            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        public bool RemoveStaffAllocation(RemoveStaffAllocationDTO obj)
        {
            bool res = false;
            SqlCommand cmd = new SqlCommand("@p_StaffAllocationId");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_StaffAllocationId", obj.StaffAllocationId);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        public List<StaffAllocationDTO> SelectStaffAllocationt()
        {
            List<StaffAllocationDTO> sad = new List<StaffAllocationDTO>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectStaff");
                cmd.CommandType = CommandType.StoredProcedure;
                sad = dblayer.GetEntityList<StaffAllocationDTO>(cmd);
            }
            return sad;
        }
    }
}