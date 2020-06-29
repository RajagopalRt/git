using EmsApi.DAL;
using EmsApi.Models.EMS;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web;
using System.Web.Http;

namespace EmsApi.Controllers.EmsControllers
{
    public class CollegeController : ApiController
    {
        //Create New FileUpload With Data
        [HttpPost]
        public HttpResponseMessage SaveCollege()
        {
            HttpResponseMessage message;


            var httpRequest = HttpContext.Current.Request.Files[0];
            var Logo = httpRequest.FileName;


            // var httpRequest = HttpContext.Current.Request.Files;
            var Name = HttpContext.Current.Request.Form[0];
            var Address = HttpContext.Current.Request.Form[1];
            var University = HttpContext.Current.Request.Form[2];
            var City = HttpContext.Current.Request.Form[3];
            var State = HttpContext.Current.Request.Form[4];
            var Country = HttpContext.Current.Request.Form[5];
            // var Logo = HttpContext.Current.Request.Form[6];
            var CompanyWebSite = HttpContext.Current.Request.Form[6];
            var ContactNumber = HttpContext.Current.Request.Form[7];
            var Email = HttpContext.Current.Request.Form[8];
            //  var CreatedBy = HttpContext.Current.Request.Form[9];

            SaveCollegeDTO save = new SaveCollegeDTO();
            save.Logo = Logo;
            save.Name = Name;
            save.Address = Address;
            save.University = Convert.ToInt32(University);
            save.City = Convert.ToInt32(City);
            save.State = Convert.ToInt32(State);
            save.Country = Convert.ToInt32(Country);
            save.CompanyWebSite = CompanyWebSite;
            save.ContactNumber = ContactNumber;
            save.Email = Email;
            // save.CreatedBy = CreatedBy;

            if (httpRequest != null && Logo != null)
            {
                var pathf = HttpContext.Current.Server.MapPath("~/UploadFile");
                var fileSavePath = Path.Combine(pathf, Logo);

                Directory.CreateDirectory(pathf);
                httpRequest.SaveAs(fileSavePath);
            }


            try
            {
                CollegeDAL dal = new CollegeDAL();
                var dynobj = new { result = dal.SaveCollege(save) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "Somthing wrong, Try Again!" });
            }

            return message;
        }
        [HttpPost]
        public HttpResponseMessage ModifyCollege(ModifyCollegeDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                CollegeDAL dal = new CollegeDAL();
                var dynobj = new { result = dal.ModifyCollege(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage RemoveCollege(RemoveCollegeDTO obj)
        {
            HttpResponseMessage message;
            try
            {
                CollegeDAL dal = new CollegeDAL();
                var dynobj = new { result = dal.RemoveCollege(obj) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectCollege()
        {
            HttpResponseMessage message;
            try
            {
                CollegeDAL dal = new CollegeDAL();
                var dynobj = dal.SelectCollege();
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectUniversity()
        {
            HttpResponseMessage message;
            try
            {
                CollegeDAL dal = new CollegeDAL();
                var dynobj = new { result = dal.SelectUniverSity() };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectState()
        {
            HttpResponseMessage message;
            try
            {
                CollegeDAL dal = new CollegeDAL();
                var dynobj = new { result = dal.SelectState() };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectCity()
        {
            HttpResponseMessage message;
            try
            {
                CollegeDAL dal = new CollegeDAL();
                var dynobj = new { result = dal.SelectCity() };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectCountry()
        {
            HttpResponseMessage message;
            try
            {
                CollegeDAL dal = new CollegeDAL();
                var dynobj = new { result = dal.SelectCountry() };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
        [HttpPost]
        public HttpResponseMessage SelectUniversityOrder()
        {
            HttpResponseMessage message;
            try
            {
                CollegeDAL dal = new CollegeDAL();
                var dynobj = new { result = dal.SelectUniverSityOne() };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "something Wrong.Try Again!" });
            }
            return message;
        }
    }
}
