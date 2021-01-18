import ballerina/log;
import ballerina/time;
import ballerinax/java.jdbc;


public type DeliveryReportPersistence object {

    private jdbc:Client jdbcClient;

    public function __init(jdbc:Client jdbcClient) {
        self.jdbcClient = jdbcClient;
    }

    public function addSuccessDelivery(SucessDeliveryDetails successDeliveryDetails) returns error? {
        jdbc:Parameter msgID = {sqlType: jdbc:TYPE_VARCHAR, value: successDeliveryDetails.msgID};
        jdbc:Parameter subsID = {sqlType: jdbc:TYPE_VARCHAR, value: successDeliveryDetails.subsID};
        jdbc:Parameter deliverySuccessDTimes = {sqlType: jdbc:TYPE_TIMESTAMP, value: successDeliveryDetails.successDeliveryDTimes};
        jdbc:Parameter createdBy = {sqlType: jdbc:TYPE_VARCHAR, value: HUB_ADMIN};
        jdbc:Parameter createdDTimes = {sqlType: jdbc:TYPE_TIMESTAMP, value: successDeliveryDetails.successDeliveryDTimes};
        jdbc:Parameter updatedBy = {sqlType: jdbc:TYPE_VARCHAR, value: ""};
        jdbc:Parameter updatedDTimes = {sqlType: jdbc:TYPE_TIMESTAMP, value: ""};
        jdbc:Parameter isDeleted = {sqlType: jdbc:TYPE_BOOLEAN, value: false};
        jdbc:Parameter deletedDTimes = {sqlType: jdbc:TYPE_TIMESTAMP, value: ""};

        var returned = self.jdbcClient->update(INSERT_INTO_SUCCESS_DELIVERY_TABLE, msgID, subsID,
            deliverySuccessDTimes, createdBy, createdDTimes, updatedBy, updatedDTimes, isDeleted, deletedDTimes);
        self.handleUpdate(returned, "insert new delivery report");
    }

    public function addFailedDelivery(FailedDeliveryDetails failedDeliveryDetails) returns error? {
        var currentUTCTime = time:format(time:currentTime(), TIMESTAMP_PATTERN);
        jdbc:Parameter msgID = {sqlType: jdbc:TYPE_VARCHAR, value: failedDeliveryDetails.msgID};
        jdbc:Parameter subsID = {sqlType: jdbc:TYPE_VARCHAR, value: failedDeliveryDetails.subsID};
        jdbc:Parameter deliveryFailureDTimes = {sqlType: jdbc:TYPE_TIMESTAMP, value: failedDeliveryDetails.failedDeliveryDTimes};
        jdbc:Parameter reason = {sqlType: jdbc:TYPE_VARCHAR, value: failedDeliveryDetails.reason};
        jdbc:Parameter failureError = {sqlType: jdbc:TYPE_VARCHAR, value: failedDeliveryDetails.failureError};
        jdbc:Parameter createdBy = {sqlType: jdbc:TYPE_VARCHAR, value: HUB_ADMIN};
        jdbc:Parameter createdDTimes = {sqlType: jdbc:TYPE_TIMESTAMP, value: failedDeliveryDetails.failedDeliveryDTimes};
        jdbc:Parameter updatedBy = {sqlType: jdbc:TYPE_VARCHAR, value: ""};
        jdbc:Parameter updatedDTimes = {sqlType: jdbc:TYPE_TIMESTAMP, value: ""};
        jdbc:Parameter isDeleted = {sqlType: jdbc:TYPE_BOOLEAN, value: false};
        jdbc:Parameter deletedDTimes = {sqlType: jdbc:TYPE_TIMESTAMP, value: ""};

        var returned = self.jdbcClient->update(INSERT_INTO_FAILED_DELIVERY_TABLE, msgID, subsID, deliveryFailureDTimes, reason, failureError,
            createdBy, createdDTimes, updatedBy, updatedDTimes, isDeleted, deletedDTimes);
        self.handleUpdate(returned, "insert new delivery report");
    }

    public function removeFailedDelivery(FailedDeliveryDetails failedDeliveryDetails) returns error? {
        var currentUTCTime = time:format(time:currentTime(), TIMESTAMP_PATTERN);
        jdbc:Parameter msgID = {sqlType: jdbc:TYPE_VARCHAR, value: failedDeliveryDetails.msgID};
        jdbc:Parameter subsID = {sqlType: jdbc:TYPE_VARCHAR, value: failedDeliveryDetails.subsID};
        jdbc:Parameter updatedBy= {sqlType: jdbc:TYPE_VARCHAR, value: HUB_ADMIN};
        jdbc:Parameter updatedDTimes = {sqlType: jdbc:TYPE_TIMESTAMP, value: currentUTCTime.toString()};
        var returned = self.jdbcClient->update(DELETE_FROM_FAILED_DELIVERY_TABLE,updatedBy,updatedDTimes, msgID, subsID);
        self.handleUpdate(returned, "remove failed query new delivery report");
    }

    function handleUpdate(jdbc:UpdateResult|jdbc:Error returned, string message) {
        if (returned is jdbc:UpdateResult) {
            log:printDebug(message + " status: " + returned.updatedRowCount.toString());
        } else {
            log:printError(message + " failed: " + <string>returned.detail()?.message);
        }
    }

};
