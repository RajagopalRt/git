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
    public class ClassDAL
    {
        public bool SaveClass(SaveClassDTO obj)
        {
            bool res = false;
            obj.CreatedBy = "1001";
            SqlCommand cmd = new SqlCommand("sp_SaveClass");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_Name", obj.Name);
            cmd.Parameters.AddWithValue("@p_Code", obj.Code);
            cmd.Parameters.AddWithValue("@p_DepartmentId", obj.DepartmentId);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.CreatedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public bool ModifyClass(ModifyClassDTO obj)
        {
            bool res = false;
            obj.ModifiedBy = "1002";
            SqlCommand cmd = new SqlCommand("sp_ModifyClass");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_ClassId", obj.ClassId);
            cmd.Parameters.AddWithValue("@p_Name", obj.Name);
            cmd.Parameters.AddWithValue("@p_Code", obj.Code);
            cmd.Parameters.AddWithValue("@p_departmentId", obj.DepartmentId);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.ModifiedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public bool RemoveClass(RemoveClassDTO obj)
        {
            bool res = false;
            SqlCommand cmd = new SqlCommand("sp_RemoveClass");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_ClassId", obj.ClassId);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        public List<ClassDTO> SelectClass()
        {
            List<ClassDTO> cls = new List<ClassDTO>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectClass");
                cmd.CommandType = CommandType.StoredProcedure;
                cls = dblayer.GetEntityList<ClassDTO>(cmd);
            }
            return cls;
        }
        public List<DepartmentName> SelectDepartmentName()
        {
            List<DepartmentName> deptName = new List<DepartmentName>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_DepartmentName");
                cmd.CommandType = CommandType.StoredProcedure;
                deptName = dblayer.GetEntityList<DepartmentName>(cmd);
            }
            return deptName;
        }
    }
}