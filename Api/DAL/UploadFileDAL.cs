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
    public class UploadFileDAL
    {
        public bool SaveUploadFile(SaveUploadFileDTO obj)
        {

            bool res = false;
            obj.CreatedBy = "1001";
            SqlCommand cmd = new SqlCommand("sp_SaveUploadFile");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@P_RegNo", obj.RegNo);
            cmd.Parameters.AddWithValue("@P_Student", obj.Student);
            cmd.Parameters.AddWithValue("@p_CollegeName", obj.CollegeName);
            cmd.Parameters.AddWithValue("@P_Department", obj.Department);
            cmd.Parameters.AddWithValue("@P_Class", obj.Class);
            cmd.Parameters.AddWithValue("@P_Section", obj.Section);
            cmd.Parameters.AddWithValue("@p_Event", obj.Event);
            cmd.Parameters.AddWithValue("@p_Title", obj.Title);
            cmd.Parameters.AddWithValue("@P_Date", obj.Date);
            cmd.Parameters.AddWithValue("@P_Place", obj.Place);
            cmd.Parameters.AddWithValue("@P_Upload", obj.Upload);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.CreatedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }



        public List<UploadFileDTO> SelectUploadFile()
        {
            List<UploadFileDTO> up = new List<UploadFileDTO>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectUploadFile");
                cmd.CommandType = CommandType.StoredProcedure;
                up = dblayer.GetEntityList<UploadFileDTO>(cmd);
            }
            return up;
        }
    }
}