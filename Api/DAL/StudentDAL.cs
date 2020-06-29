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
    public class StudentDAL
    {
        public bool SaveStudent(SaveStudentDTO obj)
        {
            bool res = false;
            obj.CreatedBy = "1001";
            SqlCommand cmd = new SqlCommand("sp_SaveStudent");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_Name", obj.Name);
            cmd.Parameters.AddWithValue("@p_Dob", obj.Dob);
            cmd.Parameters.AddWithValue("@P_DepartmentId", obj.DepartmentId);
            cmd.Parameters.AddWithValue("@P_ClassId", obj.ClassId);
            cmd.Parameters.AddWithValue("@P_SectionId", obj.SectionId);
            cmd.Parameters.AddWithValue("@P_Email", obj.Email);
            cmd.Parameters.AddWithValue("@P_Mobile", obj.Mobile);
            cmd.Parameters.AddWithValue("@P_Address", obj.Address);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.CreatedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public bool ModifyStudent(ModifyStudentDTO obj)
        {
            bool res = false;
            obj.ModifiedBy = "1002";
            SqlCommand cmd = new SqlCommand("sp_ModifyStudent");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@P_StudentId", obj.StudentId);
            cmd.Parameters.AddWithValue("@p_Name", obj.Name);
            cmd.Parameters.AddWithValue("@p_Dob", obj.Dob);
            cmd.Parameters.AddWithValue("@P_DepartmentId", obj.DepartmentId);
            cmd.Parameters.AddWithValue("@P_ClassId", obj.ClassId);
            cmd.Parameters.AddWithValue("@P_SectionId", obj.SectionId);
            cmd.Parameters.AddWithValue("@P_Email", obj.Email);
            cmd.Parameters.AddWithValue("@P_Mobile", obj.Mobile);
            cmd.Parameters.AddWithValue("@P_Address", obj.Address);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.ModifiedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        public bool RemoveStudent(RemoveStudentDTO obj)
        {
            bool res = false;
            SqlCommand cmd = new SqlCommand("sp_RemoveStudent");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_StudentId", obj.StudentId);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        public List<StudentDTO> SelectStudent()
        {
            List<StudentDTO> dept = new List<StudentDTO>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectStudent");
                cmd.CommandType = CommandType.StoredProcedure;
                dept = dblayer.GetEntityList<StudentDTO>(cmd);
            }
            return dept;
        }
        public List<SectionName> SectionName()
        {
            List<SectionName> dept = new List<SectionName>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SectionName");
                cmd.CommandType = CommandType.StoredProcedure;
                dept = dblayer.GetEntityList<SectionName>(cmd);
            }
            return dept;
        }
    }
}