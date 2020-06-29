using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using EmsApi.DAL;
using EmsApi.Models.EMS;
using System.Web;
using System.IO;
using System.Web.Http;

namespace EmsApi.Controllers.EmsControllers
{
    public class UploadFileController : ApiController
    {
        //Create New FileUpload With Data
        [HttpPost]
        public HttpResponseMessage Save()
        {
            HttpResponseMessage message;


            var httpRequest = HttpContext.Current.Request.Files[0];
            var Upload = httpRequest.FileName;


            //  var httpRequest = HttpContext.Current.Request.Files;
            var RegNo = HttpContext.Current.Request.Form[0];
            var Student = HttpContext.Current.Request.Form[1];
            var CollegeName = HttpContext.Current.Request.Form[2];
            var Department = HttpContext.Current.Request.Form[3];
            var Class = HttpContext.Current.Request.Form[4];
            var Section = HttpContext.Current.Request.Form[5];
            var Event = HttpContext.Current.Request.Form[6];
            var Title = HttpContext.Current.Request.Form[7];
            var Date = HttpContext.Current.Request.Form[8];
            var Place = HttpContext.Current.Request.Form[9];




            SaveUploadFileDTO save = new SaveUploadFileDTO();
            save.Upload = Upload;
            save.RegNo = RegNo;
            save.Student = Student;
            save.CollegeName = CollegeName;
            save.Department = Department;
            save.Class = Class;
            save.Section = Section;
            save.Event = Event;
            save.Title = Title;
            save.Date = Convert.ToDateTime(Date);
            save.Place = Place;



            if (httpRequest != null && Url != null)
            {
                var pathf = HttpContext.Current.Server.MapPath("~/UploadFile");
                var fileSavePath = Path.Combine(pathf, Upload);

                Directory.CreateDirectory(pathf);
                httpRequest.SaveAs(fileSavePath);
            }


            try
            {
                UploadFileDAL dal = new UploadFileDAL();
                var dynobj = new { result = dal.SaveUploadFile(save) };
                message = Request.CreateResponse(HttpStatusCode.OK, dynobj);
            }
            catch (Exception ex)
            {
                message = Request.CreateResponse(HttpStatusCode.BadRequest, new { msgText = "Somthing wrong, Try Again!" });
            }

            return message;
        }
        [HttpPost]
        public HttpResponseMessage Select()
        {
            HttpResponseMessage message;
            try
            {
                UploadFileDAL dal = new UploadFileDAL();
                var dynobj = new { result = dal.SelectUploadFile() };
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
