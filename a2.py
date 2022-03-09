"""
# This code is provided solely for the personal and private use of students 
# taking the CSC343H course at the University of Toronto. Copying for purposes 
# other than this use is expressly prohibited. All forms of distribution of 
# this code, including but not limited to public repositories on GitHub, 
# GitLab, Bitbucket, or any other online platform, whether as given or with 
# any changes, are expressly prohibited. 
"""

from typing import Optional
import psycopg2 as pg
import datetime

class Assignment2:

    ##### DO NOT MODIFY THE CODE BELOW. #####

    def __init__(self) -> None:
        """Initialize this class, with no database connection yet.
        """
        self.db_conn = None

    
    def connect_db(self, url: str, username: str, pword: str) -> bool:
        """Connect to the database at url and for username, and set the
        search_path to "air_travel". Return True iff the connection was made
        successfully.

        >>> a2 = Assignment2()
        >>> # This example will make sense if you change the arguments as
        >>> # appropriate for you.
        >>> a2.connect_db("csc343h-<your_username>", "<your_username>", "")
        True
        >>> a2.connect_db("test", "postgres", "password") # test doesn't exist
        False
        """
        try:
            self.db_conn = pg.connect(dbname=url, user=username, password=pword,
                                      options="-c search_path=air_travel")
        except pg.Error:
            return False

        return True

    def disconnect_db(self) -> bool:
        """Return True iff the connection to the database was closed
        successfully.

        >>> a2 = Assignment2()
        >>> # This example will make sense if you change the arguments as
        >>> # appropriate for you.
        >>> a2.connect_db("csc343h-<your_username>", "<your_username>", "")
        True
        >>> a2.disconnect_db()
        True
        """
        try:
            self.db_conn.close()
        except pg.Error:
            return False

        return True

    ##### DO NOT MODIFY THE CODE ABOVE. #####

    # ----------------------- Airline-related methods ------------------------- */

    def book_seat(self, pass_id: int, flight_id: int, seat_class: str) -> Optional[bool]:
        """Attempts to book a flight for a passenger in a particular seat class. 
        Does so by inserting a row into the Booking table.
        
        Read the handout for information on how seats are booked.

        Parameters:
        * pass_id - id of the passenger
        * flight_id - id of the flight
        * seat_class - the class of the seat

        Precondition:
        * seat_class is one of "economy", "business", or "first".
        
        Return: 
        * True iff the booking was successful.
        * False iff the seat can't be booked, or if the passenger or flight cannot be found.
        """
        try:
            # TODO: Complete this method.
            pass
        except pg.Error:
            return None


    def upgrade(self, flight_id: int) -> Optional[int]:
        """Attempts to upgrade overbooked economy passengers to business class
        or first class (in that order until each seat class is filled).
        Does so by altering the database records for the bookings such that the
        seat and seat_class are updated if an upgrade can be processed.
        
        Upgrades should happen in order of earliest booking timestamp first.
        If economy passengers are left over without a seat (i.e. not enough higher class seats), 
        remove their bookings from the database.
        
        Parameters:
        * flight_id - the flight to upgrade passengers in
        
        Precondition: 
        * flight_id exists in the database (a valid flight id).
        
        Return: 
        * The number of passengers upgraded.
        """
        try:
            # TODO: Complete this method.
            pass
        except pg.Error:
            return None


# ----------------------- Helper methods below  ------------------------- */
    

    # A helpful method for adding a timestamp to new bookings.
    def _get_current_timestamp(self):
        """Return a datetime object of the current time, formatted as required
        in our database.
        """
        return datetime.datetime.now().replace(microsecond=0)

   
    ## Add more helper methods below if desired.



# ----------------------- Testing code below  ------------------------- */

def sample_testing_function() -> None:
    a2 = Assignment2()
    # TODO: Change this to connect to your own database:
    print(a2.connect_db("csc343h-<username>", "<username>", ""))
    # TODO: Test one or more methods here.


## You can put testing code in here. It will not affect our autotester.
if __name__ == '__main__':
    # TODO: Put your testing code here, or call testing functions such as
    # this one:
    sample_testing_function()




