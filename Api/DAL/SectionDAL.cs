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
    public class SectionDAL
    {
        public bool SaveSection(SaveSectionDTO obj)
        {
            bool res = false;
            obj.CreatedBy = "1001";
            SqlCommand cmd = new SqlCommand("sp_SaveSection");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_DepartmentId", obj.DepartmentId);
            cmd.Parameters.AddWithValue("@p_Code", obj.Code);
            cmd.Parameters.AddWithValue("@p_ClassId", obj.ClassId);
            cmd.Parameters.AddWithValue("@p_Section", obj.Section);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.CreatedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public bool ModifySection(ModifySectionDTO obj)
        {
            bool res = false;
            obj.ModifiedBy = "1002";
            SqlCommand cmd = new SqlCommand("sp_ModifySection");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_ClassId", obj.ClassId);
            cmd.Parameters.AddWithValue("@p_DepartmentId", obj.DepartmentId);
            cmd.Parameters.AddWithValue("@p_Section", obj.Section);
            cmd.Parameters.AddWithValue("@p_Code", obj.Code);
            cmd.Parameters.AddWithValue("@p_SectionId", obj.SectionId);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.ModifiedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        public bool RemoveSection(RemoveSectionDTO obj)
        {
            bool res = false;
            SqlCommand cmd = new SqlCommand("sp_RemoveSection");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_SectionId", obj.SectionId);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        public List<SectionDTO> SelectSection()
        {
            List<SectionDTO> sectiondto = new List<SectionDTO>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectSection");
                cmd.CommandType = CommandType.StoredProcedure;
                sectiondto = dblayer.GetEntityList<SectionDTO>(cmd);
            }
            return sectiondto;
        }
        public List<ClassName> ClassName()
        {
            List<ClassName> ClassName = new List<ClassName>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_ClassName");
                cmd.CommandType = CommandType.StoredProcedure;
                ClassName = dblayer.GetEntityList<ClassName>(cmd);
            }
            return ClassName;
        }
    }
}