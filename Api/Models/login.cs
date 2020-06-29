using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace EmsApi.Models
{
    public class login
    {
        public string UserName { get; set; }
        public string Email { get; set; }
        public string Password { get; set; }
        public string FirstName { get; set; }
        public string LastName { get; set; }

        public string LoggedOn { get; set; }
    }
}