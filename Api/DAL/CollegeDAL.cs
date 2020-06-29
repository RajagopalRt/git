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
    public class CollegeDAL
    {
        public bool SaveCollege(SaveCollegeDTO obj)
        {
            bool res = false;
            obj.CreatedBy = "1001";
            SqlCommand cmd = new SqlCommand("sp_SaveCollege");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_Name", obj.Name);
            cmd.Parameters.AddWithValue("@p_Address", obj.Address);
            cmd.Parameters.AddWithValue("@p_University", obj.University);
            cmd.Parameters.AddWithValue("@p_City", obj.City);
            cmd.Parameters.AddWithValue("@p_State", obj.State);
            cmd.Parameters.AddWithValue("@p_Country", obj.Country);
            cmd.Parameters.AddWithValue("@p_Logo", obj.Logo);
            cmd.Parameters.AddWithValue("@p_CompanyWebsite", obj.CompanyWebSite);
            cmd.Parameters.AddWithValue("@p_ContactNumber", obj.ContactNumber);
            cmd.Parameters.AddWithValue("@p_Email", obj.Email);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.CreatedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }
        public bool ModifyCollege(ModifyCollegeDTO obj)
        {
            bool res = false;
            obj.ModifiedBy = "1002";
            SqlCommand cmd = new SqlCommand("sp_ModifyCollege");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_CollegeId", obj.CollegeId);
            cmd.Parameters.AddWithValue("@p_Name", obj.Name);
            cmd.Parameters.AddWithValue("@p_Address", obj.Address);
            cmd.Parameters.AddWithValue("@p_University", obj.University);
            cmd.Parameters.AddWithValue("@p_City", obj.City);
            cmd.Parameters.AddWithValue("@p_State", obj.State);
            cmd.Parameters.AddWithValue("@p_Country", obj.Country);
            cmd.Parameters.AddWithValue("@p_Logo", obj.Logo);
            cmd.Parameters.AddWithValue("@p_CompanyWebsite", obj.CompanyWebSite);
            cmd.Parameters.AddWithValue("@p_ContactNumber", obj.ContactNumber);
            cmd.Parameters.AddWithValue("@p_Email", obj.Email);
            cmd.Parameters.AddWithValue("@p_ActionBy", obj.ModifiedBy);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        public bool RemoveCollege(RemoveCollegeDTO obj)
        {
            bool res = false;
            SqlCommand cmd = new SqlCommand("sp_RemoveCollege");
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.AddWithValue("@p_CollegeId", obj.CollegeId);
            int result = new DBlayer().ExecuteNonQuery(cmd);
            if (result != Int32.MaxValue)
            {
                res = true;
            }
            return res;
        }

        public List<CollegeDTO> SelectCollege()
        {
            List<CollegeDTO> clg = new List<CollegeDTO>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectCollege");
                cmd.CommandType = CommandType.StoredProcedure;
                clg = dblayer.GetEntityList<CollegeDTO>(cmd);
            }
            return clg;
        }
        public List<UniverSityMaster> SelectUniverSity()
        {
            List<UniverSityMaster> uni = new List<UniverSityMaster>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectUniverSity");
                cmd.CommandType = CommandType.StoredProcedure;
                uni = dblayer.GetEntityList<UniverSityMaster>(cmd);
            }
            return uni;
        }
        public List<StateMaster> SelectState()
        {
            List<StateMaster> state = new List<StateMaster>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectState");
                cmd.CommandType = CommandType.StoredProcedure;
                state = dblayer.GetEntityList<StateMaster>(cmd);
            }
            return state;
        }
        public List<CityMaster> SelectCity()
        {
            List<CityMaster> City = new List<CityMaster>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectCity");
                cmd.CommandType = CommandType.StoredProcedure;
                City = dblayer.GetEntityList<CityMaster>(cmd);
            }
            return City;
        }
        public List<CountryMaster> SelectCountry()
        {
            List<CountryMaster> Country = new List<CountryMaster>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_SelectCountry");
                cmd.CommandType = CommandType.StoredProcedure;
                Country = dblayer.GetEntityList<CountryMaster>(cmd);
            }
            return Country;
        }
        public List<UniverSityMaster> SelectUniverSityOne()
        {
            List<UniverSityMaster> univer = new List<UniverSityMaster>();
            using (DBlayer dblayer = new DBlayer())
            {
                SqlCommand cmd = new SqlCommand("sp_UniversityOrder");
                cmd.CommandType = CommandType.StoredProcedure;
                univer = dblayer.GetEntityList<UniverSityMaster>(cmd);
            }
            return univer;
        }
    }
}