const googlePlacesService = require('../services/googlePlacesService');

/**
 * GET /api/healthcare/nearby
 * Returns nearby healthcare facilities with category filter and GPS distance
 */
async function getNearby(req, res) {
    try {
        const { latitude, longitude, radius, category } = req.query;

        const results = await googlePlacesService.searchNearbyHealthcare({
            latitude,
            longitude,
            radius: radius ? parseInt(radius, 10) : 25000,
            category: category || 'all',
        });

        res.status(200).json({
            status: 'success',
            count: results.length,
            data: results,
        });
    } catch (err) {
        console.error('[healthcareController] getNearby error:', err);
        res.status(500).json({
            status: 'error',
            message: 'Failed to retrieve nearby healthcare facilities.',
        });
    }
}

/**
 * GET /api/healthcare/details/:placeId
 * Returns detailed information about a healthcare facility
 */
async function getDetails(req, res) {
    try {
        const { placeId } = req.params;
        if (!placeId) {
            return res.status(400).json({
                status: 'error',
                message: 'Place ID is required.',
            });
        }

        const facility = await googlePlacesService.getHealthcarePlaceDetails(placeId);
        res.status(200).json({
            status: 'success',
            data: facility,
        });
    } catch (err) {
        console.error('[healthcareController] getDetails error:', err);
        res.status(500).json({
            status: 'error',
            message: 'Failed to retrieve facility details.',
        });
    }
}

/**
 * GET /api/healthcare/directions
 * Returns route directions, distance, and duration between two coordinates
 */
async function getDirections(req, res) {
    try {
        const { originLat, originLng, destLat, destLng } = req.query;
        if (!originLat || !originLng || !destLat || !destLng) {
            return res.status(400).json({
                status: 'error',
                message: 'originLat, originLng, destLat, and destLng query parameters are required.',
            });
        }

        const directions = await googlePlacesService.getDirections({
            originLat,
            originLng,
            destLat,
            destLng,
        });

        res.status(200).json({
            status: 'success',
            data: directions,
        });
    } catch (err) {
        console.error('[healthcareController] getDirections error:', err);
        res.status(500).json({
            status: 'error',
            message: 'Failed to retrieve directions.',
        });
    }
}

module.exports = {
    getNearby,
    getDetails,
    getDirections,
};
