from .dashboard_controller import (
    get_dashboard, create_dashboard, update_dashboard, delete_dashboard,
    get_dashboard_tabs, create_dashboard_tab, update_dashboard_tab, delete_dashboard_tab,
    get_all_tab_widgets, add_tab_widget, update_tab_widget, delete_tab_widget
)     

from .oauth_controller import oauth_login, oauth_callback

from .widgets_controller import (
    get_widget, get_all_widgets, create_widget, update_widget, delete_widget
)
