using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Runtime.Serialization;
namespace WB
{
    public class DTOBase : INotifyPropertyChanged
    {
        private DataRowState base_state;
        [DataMember]
        public Dictionary<string, object> original = new Dictionary<string, object>();
        [DataMember]
        internal bool isInit = true;
        private string stf_no = (string)null;
        private string ip_addr = (string)null;

        public object this[string Name] => this.GetType().GetProperty(Name).GetValue((object)this, (object[])null);

        public object this[string Name, DataRowVersion dv] => dv == DataRowVersion.Original ? this.original[Name] : this.GetType().GetProperty(Name).GetValue((object)this, (object[])null);

        [DataMember]
        public DataRowState BASE_STATE
        {
            get => this.base_state;
            set
            {
                if (this.base_state == value)
                    return;
                this.base_state = value;
                this.OnPropertyChanged(nameof(BASE_STATE), (object)value);
            }
        }

        public void EndInit()
        {
            this.isInit = false;
            this.AcceptChanges();
        }

        public void RejectChanges()
        {
            foreach (string key1 in this.original.Keys)
            {
                string key = key1;
                if (((IEnumerable<PropertyInfo>)this.GetType().GetProperties()).Where<PropertyInfo>((Func<PropertyInfo, bool>)(p => p.Name == key)).Count<PropertyInfo>() > 0)
                    this.GetType().GetProperty(key).SetValue((object)this, this.original[key], (object[])null);
            }
            this.GetType().GetProperty("BASE_STATE").SetValue((object)this, (object)DataRowState.Unchanged, (object[])null);
        }

        public void AcceptChanges()
        {
            foreach (PropertyInfo property in this.GetType().GetProperties())
            {
                if (property.GetSetMethod() != (MethodInfo)null)
                    this.original[property.Name] = property.GetValue((object)this, (object[])null);
            }
            this.GetType().GetProperty("BASE_STATE").SetValue((object)this, (object)DataRowState.Unchanged, (object[])null);
        }

        [field: NonSerialized]
        public event PropertyChangedEventHandler PropertyChanged;

        protected void OnPropertyChanged(string propertyName, object value)
        {
            if (this.PropertyChanged != null)
                this.PropertyChanged((object)this, new PropertyChangedEventArgs(propertyName));
            if (this.isInit || propertyName.Equals("BASE_STATE") || this.BASE_STATE.Equals((object)DataRowState.Added) || this.BASE_STATE.Equals((object)DataRowState.Deleted))
                return;
            this.BASE_STATE = DataRowState.Modified;
        }

        protected void OnPropertyChanged(string propertyName)
        {
            if (!this.isInit && !propertyName.Equals("BASE_STATE") && !this.BASE_STATE.Equals((object)DataRowState.Added) && !this.BASE_STATE.Equals((object)DataRowState.Deleted))
                this.BASE_STATE = DataRowState.Modified;
            if (this.PropertyChanged == null)
                return;
            this.PropertyChanged((object)this, new PropertyChangedEventArgs(propertyName));
        }

        [Category("HIS")]
        public string HIS_STF_NO
        {
            get => this.stf_no;
            set
            {
                if (!(this.stf_no != value))
                    return;
                this.stf_no = value;
            }
        }

        [Category("HIS")]
        public string HIS_IP_ADDR
        {
            get => this.ip_addr;
            set
            {
                if (!(this.ip_addr != value))
                    return;
                this.ip_addr = value;
            }
        }

    }
}
