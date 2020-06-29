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
    public class CommonT_LoginDAL
    {
        public bool SaveCommonT_Login(SaveCommonT_LoginDTO obj)
        {
            bool res = false;
            SqlCommand cmd = new SqlCommand("sp_SaveCommonT_Login");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_Name", obj.Name);
            cmd.Parameters.AddWithValue("@p_UserName", obj.UserName);
            cmd.Parameters.AddWithValue("@p_PassWord", obj.PassWord);
            cmd.Parameters.AddWithValue("@p_Role", obj.Role);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public bool ModifyCommonT_Login(ModifyCommonT_LoginDTO obj)
        {
            bool res = false;
            SqlCommand cmd = new SqlCommand("sp_ModifyCommonT_Login");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_Id", obj.Id);
            cmd.Parameters.AddWithValue("@p_Name", obj.Name);
            cmd.Parameters.AddWithValue("@p_UserName", obj.UserName);
            cmd.Parameters.AddWithValue("@p_PassWord", obj.PassWord);
            cmd.Parameters.AddWithValue("@p_Role", obj.Role);
            cmd.Parameters.AddWithValue("@p_Active", obj.Active);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public List<SelectCommonT_LoginDTO> SelectCommonT_Login(SelectCommonT_LoginProcDTO obj)
        {
            List<SelectCommonT_LoginDTO> commont_logindto = new List<SelectCommonT_LoginDTO>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectCommonT_Login");
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@p_UserName", obj.UserName);
                cmd.Parameters.AddWithValue("@p_PassWord", obj.PassWord);
                commont_logindto = dblayer.GetEntityList<SelectCommonT_LoginDTO>(cmd);
            }
            return commont_logindto;
        }
    }
}