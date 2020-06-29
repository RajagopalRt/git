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
    public class RoleDAL
    {
        public bool SaveRole(SaveRoleDTO obj)
        {
            bool res = false;
            obj.CreatedBy = "1001";
            SqlCommand cmd = new SqlCommand("sp_SaveRole");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_Name", obj.Name);
            cmd.Parameters.AddWithValue("@p_Code", obj.Code);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.CreatedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        public bool ModifyRole(ModifyRoleDTO obj)
        {
            bool res = false;
            obj.ModifiedBy = "1002";
            SqlCommand cmd = new SqlCommand("sp_ModifyRole");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@P_RoleId", obj.RoleId);
            cmd.Parameters.AddWithValue("@p_Name", obj.Name);
            cmd.Parameters.AddWithValue("@p_Code", obj.Code);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.ModifiedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public bool RemoveRole(RemoveRoleDTO obj)
        {
            bool res = false;
            SqlCommand cmd = new SqlCommand("sp_RemoveRole");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@P_RoleId", obj.RoleId);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        public List<RoleDTO> SelectRole()
        {
            List<RoleDTO> dept = new List<RoleDTO>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectRole");
                cmd.CommandType = CommandType.StoredProcedure;
                dept = dblayer.GetEntityList<RoleDTO>(cmd);
            }
            return dept;
        }
    }
}