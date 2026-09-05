const request = require('supertest');
const { createApp } = require('../src/app');

describe('GPS Healthcare Finder API', () => {
    let app;

    beforeAll(() => {
        app = createApp();
    });

    describe('GET /api/healthcare/nearby', () => {
        it('returns nearby healthcare facilities with default all category', async () => {
            const res = await request(app)
                .get('/api/healthcare/nearby?latitude=17.6805&longitude=74.0183&radius=25000')
                .expect(200);

            expect(res.body.status).toBe('success');
            expect(Array.isArray(res.body.data)).toBe(true);
            expect(res.body.data.length).toBeGreaterThan(0);

            const first = res.body.data[0];
            expect(first).toHaveProperty('id');
            expect(first).toHaveProperty('name');
            expect(first).toHaveProperty('category');
            expect(first).toHaveProperty('address');
            expect(first).toHaveProperty('distance');
            expect(first).toHaveProperty('distanceKm');
            expect(first).toHaveProperty('latitude');
            expect(first).toHaveProperty('longitude');
        });

        it('filters by category hospitals', async () => {
            const res = await request(app)
                .get('/api/healthcare/nearby?latitude=17.6805&longitude=74.0183&category=hospitals')
                .expect(200);

            expect(res.body.status).toBe('success');
            expect(res.body.data.length).toBeGreaterThan(0);
            res.body.data.forEach((item) => {
                expect(item.category.toLowerCase().includes('hospital') || item.type.toLowerCase().includes('hospital')).toBe(true);
            });
        });

        it('filters by category pharmacies', async () => {
            const res = await request(app)
                .get('/api/healthcare/nearby?latitude=17.6805&longitude=74.0183&category=pharmacies')
                .expect(200);

            expect(res.body.status).toBe('success');
            expect(res.body.data.length).toBeGreaterThan(0);
            res.body.data.forEach((item) => {
                expect(item.category.toLowerCase().includes('pharmac') || item.type.toLowerCase().includes('pharmacy')).toBe(true);
            });
        });

        it('filters by emergency category', async () => {
            const res = await request(app)
                .get('/api/healthcare/nearby?latitude=17.6805&longitude=74.0183&category=emergency')
                .expect(200);

            expect(res.body.status).toBe('success');
            expect(res.body.data.length).toBeGreaterThan(0);
            res.body.data.forEach((item) => {
                expect(item.isEmergency24x7).toBe(true);
            });
        });

        it('filters by maternal care category', async () => {
            const res = await request(app)
                .get('/api/healthcare/nearby?latitude=17.6805&longitude=74.0183&category=maternity')
                .expect(200);

            expect(res.body.status).toBe('success');
            expect(res.body.data.length).toBeGreaterThan(0);
            res.body.data.forEach((item) => {
                expect(item.hasMaternalCare).toBe(true);
            });
        });
    });

    describe('GET /api/healthcare/details/:placeId', () => {
        it('returns details for a valid placeId', async () => {
            const res = await request(app)
                .get('/api/healthcare/details/place_satara_dist_hosp')
                .expect(200);

            expect(res.body.status).toBe('success');
            expect(res.body.data.id).toBe('place_satara_dist_hosp');
            expect(res.body.data.name).toContain('Satara District');
            expect(res.body.data.phone).toBeTruthy();
            expect(res.body.data.isEmergency24x7).toBe(true);
            expect(res.body.data.hasMaternalCare).toBe(true);
        });
    });

    describe('GET /api/healthcare/directions', () => {
        it('returns directions between origin and destination coordinates', async () => {
            const res = await request(app)
                .get('/api/healthcare/directions?originLat=17.6805&originLng=74.0183&destLat=17.7012&destLng=74.1754')
                .expect(200);

            expect(res.body.status).toBe('success');
            expect(res.body.data).toHaveProperty('distance');
            expect(res.body.data).toHaveProperty('duration');
            expect(res.body.data).toHaveProperty('googleMapsNavigationUrl');
            expect(res.body.data.googleMapsNavigationUrl).toContain('google.com/maps/dir');
        });

        it('returns 400 if coordinates are missing', async () => {
            await request(app)
                .get('/api/healthcare/directions?originLat=17.6805')
                .expect(400);
        });
    });
});
