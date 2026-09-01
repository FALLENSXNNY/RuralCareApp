// Facility and Doctor Controller for Phase 5
const facilityService = require('../services/facilityService');

/**
 * GET /api/v1/facilities
 */
async function getFacilities(req, res, next) {
    try {
        const facilities = await facilityService.getFacilities(req.query);
        return res.status(200).json({
            facilities,
        });
    } catch (err) {
        return next(err);
    }
}

/**
 * GET /api/v1/facilities/:id
 */
async function getFacilityById(req, res, next) {
    try {
        const facility = await facilityService.getFacilityById(req.params.id);
        if (!facility) {
            return res.status(404).json({
                error: 'NOT_FOUND',
                message: 'Facility not found.',
            });
        }
        return res.status(200).json({
            facility,
        });
    } catch (err) {
        return next(err);
    }
}

/**
 * GET /api/v1/doctors
 */
async function getDoctors(req, res, next) {
    try {
        const doctors = await facilityService.getDoctors(req.query);
        return res.status(200).json({
            doctors,
        });
    } catch (err) {
        return next(err);
    }
}

/**
 * GET /api/v1/doctors/:id
 */
async function getDoctorById(req, res, next) {
    try {
        const doctor = await facilityService.getDoctorById(req.params.id);
        if (!doctor) {
            return res.status(404).json({
                error: 'NOT_FOUND',
                message: 'Doctor not found.',
            });
        }
        return res.status(200).json({
            doctor,
        });
    } catch (err) {
        return next(err);
    }
}

module.exports = {
    getFacilities,
    getFacilityById,
    getDoctors,
    getDoctorById,
};
