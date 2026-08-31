abstract class ApiEndpoints {
  /// -- Booking --

  /// GET booking by Id.
  static String getBookingById(String id) => '/api/Booking/$id';
  /// GET the current user's next upcoming booking (or null).
  static const String getNextUpcomingBooking = '/api/Booking/upcoming';
  /// GET bookings by Business.
  static String getAllBookingsByBusinessId(String id) => '/api/Booking/business/$id';
  /// GET bookings for employee.
  static const String getMyEmployeeBookings = '/api/Booking/mine/employee';
  /// GET bookings by user.
  static const String getMineBookings = '/api/Booking/mine';
  /// POST create booking.
  static const String createBooking = '/api/Booking';
  /// PUT cancel booking.
  static String cancelBooking(String id) => '/api/Booking/$id/cancel';
  /// DELETE delete booking.
  static String deleteBooking(String id) => '/api/Booking/$id';


  /// -- Business --
  /// GET all businesses.
  static const String getAllBusinesses = '/api/Business';
  /// GET 7 newest businesses.
  static const String getNewestBusinesses = '/api/Business/newest';
  /// GET 7 top-rated businesses.
  static const String getTopRatedBusinesses = '/api/Business/top-rated';
  /// GET businesses by name (search).
  static const String searchBusinesses = '/api/Business/search';
  /// GET all businesses by category Id.
  static String getAllBusinessesByCategory(String id) => '/api/Category/$id/businesses';
  /// GET business by Id.
  static String getBusinessById(String id) => '/api/Business/$id';
  /// GET mine business.
  static const String getMineBusiness = '/api/Business/mine';
  /// POST register/create a business.
  static const String createBusiness = '/api/Business/register';
  /// PUT edit business.
  static String updateBusiness(String id) => '/api/Business/$id';
  /// DELETE delete business.
  static String deleteBusiness(String id) => '/api/Business/$id';


  /// -- Category --
  /// GET all categories.
  static const String getAllCategories = '/api/Category';
  /// GET category by Id.
  static String getCategoryById(String id) => '/api/Category/$id';
  /// POST create category - Only Admin
  static const String createCategory = '/api/Category';
  /// PUT edit category.
  static String updateCategory(String id) => '/api/Category/$id';
  /// DELETE delete category.
  static String deleteCategory(String id) => '/api/Category/$id';


  /// -- Employee --
  /// GET all employees.
  static const String getAllEmployees = '/api/Employee';
  /// GET all employees by business Id.
  static String getAllEmployeesByBusiness(String id) => '/api/Business/$id/employees';
  /// GET all bookable employees
  static String getBookableEmployeesByBusiness(String businessId) => '/api/Employee/business/$businessId/bookable';
  /// GET employee job.
  static const String getMyEmployment = '/api/Employee/mine';
  /// GET employee by Id.
  static String getEmployeeById(String id) => '/api/Employee/$id';
  /// POST create employee.
  static const String createEmployee = '/api/Employee';
  /// PUT edit employee.
  static String updateEmployee(String id) => '/api/Employee/$id';
  /// DELETE delete employee.
  static String deleteEmployee(String id) => '/api/Employee/$id';


  /// -- Review --
  /// GET reviews by user.
  static const String getMineReviews = '/api/Review/mine';
  /// GET review by Id.
  static String getReviewById(String id) => '/api/Review/$id';
  /// GET reviews by business Id.
  static String getAllReviewsByBusiness(String id) => '/api/Review/business/$id';
  /// POST create review.
  static const String createReview = '/api/Review';
  /// PUT edit review.
  static String updateReview(String id) => '/api/Review/$id';
  /// DELETE delete review.
  static String deleteReview(String id) => '/api/Review/$id';


  /// -- WorkSchedule --
  /// GET schedule by Id.
  static String getScheduleByBusinessId(String id) => '/api/Schedule/$id';
  /// POST create work schedule.
  static const String createSchedule = '/api/Schedule/create';
  /// PUT edit schedule.
  static String updateSchedule(String id) => '/api/Schedule/$id';


  /// -- Term --
  static String getTermsByEmployee(String id) => '/api/Term/employee/$id';

  /// -- User --
  /// GET current user profile.
  static const String getCurrentUser = '/api/User/me';
  /// PUT edit current user profile.
  static const String updateCurrentUser = '/api/User/me';

  /// -- Business Image --
  /// POST upload business logo
  static String uploadBusinessLogo(String businessId) => '/api/Business/$businessId/logo';
  /// POST add business images
  static String addBusinessImage(String businessId) => '/api/Business/$businessId/images';
  /// DELETE business image
  static String deleteBusinessImage(String businessId, String imageId) => '/api/Business/$businessId/images/$imageId';
}