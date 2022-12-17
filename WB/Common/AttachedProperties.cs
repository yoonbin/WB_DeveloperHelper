using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Collections.Specialized;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using WB.DTO;
using WB.UC;

namespace WB.Common
{
    // Adds a collection of command bindings to a date picker's existing BlackoutDates collection, since the collections are immutable and can't be bound to otherwise.
    // Usage: <DatePicker hacks:AttachedProperties.RegisterBlackoutDates="{Binding BlackoutDates}" >
    public class CalendarAttachedProperties : DependencyObject
    {
        #region Attributes

        private static readonly List<Calendar> _calendars = new List<Calendar>();
        private static readonly List<DatePicker> _datePickers = new List<DatePicker>();
        
        #endregion

        #region Dependency Properties

        public static DependencyProperty RegisterBlackoutDatesProperty = 
            DependencyProperty.RegisterAttached("RegisterBlackoutDates"
                , typeof(ObservableCollection<DateTime>)
                , typeof(CalendarAttachedProperties)
                , new PropertyMetadata(null, OnRegisterCommandBindingChanged));

        public static ObservableCollection<DateTime> GetRegisterBlackoutDates(DependencyObject d)
        {
            return (ObservableCollection<DateTime>)d.GetValue(RegisterBlackoutDatesProperty);
        }

        public static void SetRegisterBlackoutDates(DependencyObject d, ObservableCollection<DateTime> value)
        {
            d.SetValue(RegisterBlackoutDatesProperty, value);
        }
       

        public static readonly DependencyProperty SingleClickDefocusProperty =
        DependencyProperty.RegisterAttached("SingleClickDefocus", typeof(bool), typeof(Calendar)
        , new FrameworkPropertyMetadata(false, new PropertyChangedCallback(SingleClickDefocusChanged)));

        public static bool GetSingleClickDefocus(DependencyObject obj)
        {
            return (bool)obj.GetValue(SingleClickDefocusProperty);
        }

        public static void SetSingleClickDefocus(DependencyObject obj, bool value)
        {
            obj.SetValue(SingleClickDefocusProperty, value);
        }

        #endregion

        #region Event Handlers
        private static void SingleClickDefocusChanged(DependencyObject d, DependencyPropertyChangedEventArgs e)
        {
            if (d is Calendar)
            {
                Calendar calendar = d as Calendar;
                calendar.PreviewMouseDown += (a, b) =>
                {
                    if (Mouse.Captured is Calendar || Mouse.Captured is System.Windows.Controls.Primitives.CalendarItem)
                    {
                        Mouse.Capture(null);
                    }
                };
            }
        }
        private static void CalendarBindings_CollectionChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            ObservableCollection<DateTime> blackoutDates = sender as ObservableCollection<DateTime>;

            Calendar calendar = _calendars.First(c => c.Tag == blackoutDates);

            if (e.Action == NotifyCollectionChangedAction.Add)
            {
                foreach (DateTime date in e.NewItems)
                {
                    calendar.BlackoutDates.Add(new CalendarDateRange(date));
                }
            }
        }

        private static void DatePickerBindings_CollectionChanged(object sender, System.Collections.Specialized.NotifyCollectionChangedEventArgs e)
        {
            ObservableCollection<DateTime> blackoutDates = sender as ObservableCollection<DateTime>;

            DatePicker datePicker = _datePickers.First(c => c.Tag == blackoutDates);

            if (e.Action == NotifyCollectionChangedAction.Add)
            {
                foreach (DateTime date in e.NewItems)
                {
                    datePicker.BlackoutDates.Add(new CalendarDateRange(date));
                }
            }
        }

        #endregion

        #region Private Methods

        private static void OnRegisterCommandBindingChanged(DependencyObject sender, DependencyPropertyChangedEventArgs e)
        {
            Calendar calendar = sender as Calendar;
            if (calendar != null)
            {
                ObservableCollection<DateTime> bindings = e.NewValue as ObservableCollection<DateTime>;
                if (bindings != null)
                {
                    if (!_calendars.Contains(calendar))
                    {
                        calendar.Tag = bindings;
                        _calendars.Add(calendar);
                    }

                    calendar.BlackoutDates.Clear();
                    foreach (DateTime date in bindings)
                    {
                        calendar.BlackoutDates.Add(new CalendarDateRange(date));
                    }
                    bindings.CollectionChanged += CalendarBindings_CollectionChanged;
                }
            }
            else
            {
                DatePicker datePicker = sender as DatePicker;
                if (datePicker != null)
                {
                    ObservableCollection<DateTime> bindings = e.NewValue as ObservableCollection<DateTime>;
                    if (bindings != null)
                    {
                        if (!_datePickers.Contains(datePicker))
                        {
                            datePicker.Tag = bindings;
                            _datePickers.Add(datePicker);
                        }

                        datePicker.BlackoutDates.Clear();
                        foreach (DateTime date in bindings)
                        {
                            datePicker.BlackoutDates.Add(new CalendarDateRange(date));
                        }
                        bindings.CollectionChanged += DatePickerBindings_CollectionChanged;
                    }
                }
            }
        }
       
        #endregion
    }

    public class DataGridAttachedProperties : DependencyObject
    {
        public static readonly DependencyProperty RegisterSelectionUnitProperty =
           DependencyProperty.RegisterAttached("RegisterSelectionUnit"
               , typeof(DataGridSelectionUnit)
               , typeof(DataGridAttachedProperties)
               , new FrameworkPropertyMetadata(OnRegisterSelectionUnitPropertyChanged) { BindsTwoWayByDefault = true });

       
        public static DataGridSelectionUnit GetRegisterSelectionUnit(DependencyObject d)
        {
            return (DataGridSelectionUnit)d.GetValue(RegisterSelectionUnitProperty);
        }

        public static void SetRegisterSelectionUnit(DependencyObject d, DataGridSelectionUnit value)
        {
            d.SetValue(RegisterSelectionUnitProperty, value);
        }

        private static void OnRegisterSelectionUnitPropertyChanged(DependencyObject sender, DependencyPropertyChangedEventArgs e)
        {
            DataGrid dataGrid = sender as DataGrid;
            if (dataGrid != null)
            {
                dataGrid.SelectionUnit = (DataGridSelectionUnit)e.NewValue;
                
            }
            else
            {
            }
        }
    }
}
